import dbus
import dbus.service
import dbus.exceptions
from syslog import syslog, openlog
from dbus.mainloop.glib import DBusGMainLoop
import sys
import logging

from gi.repository import GObject as gobject
from gi.repository import GLib as glib

loop = None

# Ofono DBus Paths
OFONO_ROOT_PATH = '/'
OFONO_BUS_NAME = 'org.ofono'
OFONO_MANAGER_IFACE = 'org.ofono.Manager'
OFONO_MODEM_IFACE = 'org.ofono.Modem'
OFONO_SIM_IFACE = 'org.ofono.SimManager'
OFONO_NETREG_IFACE = 'org.ofono.NetworkRegistration'
OFONO_CONNMAN_IFACE = 'org.ofono.ConnectionManager'
OFONO_CONNECTION_IFACE = 'org.ofono.ConnectionContext'

GEMALTO_MODEM_MODEL = 'PLS62-W'

# LTE Wake GPIO path
LTE_WAKE_GPIO_PATH = '/sys/devices/platform/gpio/lte_on/value'

def dbus_to_python(data):
    if isinstance(data, dbus.String):
        data = str(data)
    elif isinstance(data, dbus.Boolean):
        data = bool(data)
    elif isinstance(data, dbus.Int64):
        data = int(data)
    elif isinstance(data, dbus.Byte):
        data = int(data)
    elif isinstance(data, dbus.Double):
        data = float(data)
    elif isinstance(data, list):
        data = [dbus_to_python(value) for value in data]
    elif isinstance(data, dict):
        new_data = dict()
        for key in data.keys():
            new_data[dbus_to_python(key)] = dbus_to_python(data[key])
        data = new_data
    return data

class LTEHelper():
    def __init__(self):
        self.modem = None
        self.modem_path = None
        self.modem_sim = None
        self.modem_netreg = None
        self.modem_connman = None
        self.modem_context = None
        try:
            self.bus = dbus.SystemBus()
            self.ofono = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, OFONO_ROOT_PATH), OFONO_MANAGER_IFACE)
            self.ofono.connect_to_signal('ModemAdded', self.modem_added)
        except dbus.DBusException:
            self.ofono = None
            logging.warn('Ofono not available!')

    def modem_added(self, object_path, properties):
        logging.info('Modem Detected: {}'.format(object_path))
        self.modem_path = object_path
        self.modem = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, object_path), OFONO_MODEM_IFACE)
        self.modem.connect_to_signal('PropertyChanged', self.modem_prop_changed)
        self.modem.SetProperty('Powered', True)

    def modem_prop_changed(self, name, value):
        if self.modem is not None and name == 'Interfaces':
            if OFONO_SIM_IFACE in value:
                if self.modem_sim is None:
                    self.modem_sim = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, self.modem_path), OFONO_SIM_IFACE)
                    self.modem_sim.connect_to_signal('PropertyChanged', self.modem_sim_property_changed)
                    p = self.modem_sim.GetProperties()
                    if 'Present' in p and p['Present'] == True:
                        logging.info('SIM detected.')
            elif self.modem_sim is not None:
                self.modem_sim = None
            if OFONO_CONNMAN_IFACE in value:
                if self.modem_connman is None:
                    logging.info('Modem connection manager available.')
                    self.modem_connman = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, self.modem_path), OFONO_CONNMAN_IFACE)
                    self.modem_connman.connect_to_signal('PropertyChanged', self.modem_conn_property_changed)
                    ctxs = self.modem_connman.GetContexts()
                    if len(ctxs) > 0:
                        self.modem_context = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, ctxs[0][0]), OFONO_CONNECTION_IFACE)
                        logging.info('Context found: {}'.format(dbus_to_python(self.modem_context.GetProperties())))
                        self.modem_context.connect_to_signal('PropertyChanged', self.context_prop_changed)
                    else:
                        self.modem_connman.connect_to_signal('ContextAdded', self.context_added)
            elif self.modem_connman is not None:
                logging.info('Modem connection manager unavailable.')
                self.modem_connman = None
            if OFONO_NETREG_IFACE in value:
                if self.modem_netreg is None:
                    logging.info('Modem network now available.')
                    self.modem_netreg = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME,self.modem_path), OFONO_NETREG_IFACE)
                    self.modem_netreg.connect_to_signal('PropertyChanged', self.modem_net_property_changed)
            elif self.modem_netreg is not None:
                logging.warn('Modem network now unavailable.')
                self.modem_netreg = None
        if name == 'Model' and value == GEMALTO_MODEM_MODEL:
            logging.info('Modem configured, going online.')
            self.modem.SetProperty('Online', True)

    def modem_sim_property_changed(self, name, value):
        logging.info('SIM {} is now {}'.format(name, dbus_to_python(value)))

    def modem_net_property_changed(self, name, value):
        logging.info('Network {} is now {}'.format(name, dbus_to_python(value) if value else '(Empty)'))

    def modem_conn_property_changed(self, name, value):
        logging.info('Connection {} is now {}'.format(name, dbus_to_python(value) if value else '(Empty)'))

    def context_added(self, path, props):
        if self.modem_context is None:
            self.modem_context = dbus.Interface(self.bus.get_object(OFONO_BUS_NAME, path), OFONO_CONNECTION_IFACE)
            logging.info('Context added: {}'.format(dbus_to_python(props)))
            self.modem_context.connect_to_signal('PropertyChanged', self.context_prop_changed)

    def context_prop_changed(self, name, value):
        logging.info('Context {} is now {}'.format(name, dbus_to_python(value)))

    def lte_wake(self):
        logging.info('Waking LTE module')
        # Wake LTE module with falling edge
        with open(LTE_WAKE_GPIO_PATH, 'w') as f:
            f.write('%d' % int(0))

def main():
    # Initialize a main loop
    DBusGMainLoop(set_as_default=True)

    loop = glib.MainLoop()

    # Run the loop
    try:
        lte = LTEHelper()
        lte.lte_wake()
        loop.run()
    finally:
        loop.quit()
    return 0

#
# Configure logging
#
logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)

#
# Run the service!
#
logging.info("Starting main loop.")
main()
