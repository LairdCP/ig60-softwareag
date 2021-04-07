################################################################################
#
# cumulocity-agent
#
################################################################################

CUMULOCITY_AGENT_VERSION = v4.2.9
CUMULOCITY_AGENT_SITE = https://bitbucket.org/m2m/cumulocity-agents-linux.git
CUMULOCITY_AGENT_SITE_METHOD = git
CUMULOCITY_AGENT_DEPENDENCIES = cumulocity-sdk-c libmodbus
CUMULOCITY_AGENT_INSTALL_STAGING = NO
CUMULOCITY_AGENT_LICENSE = MIT
CUMULOCITY_AGENT_LICENSE_FILES = COPYRIGHT

define CUMULOCITY_AGENT_BUILD_CMDS
    $(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) release vnc
endef

define CUMULOCITY_AGENT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/bin/cumulocity-agent $(TARGET_DIR)/usr/bin/
    $(INSTALL) -D -m 0755 $(@D)/bin/vncproxy $(TARGET_DIR)/usr/bin/
    mkdir -p $(TARGET_DIR)/usr/share/cumulocity-agent
    mkdir -p $(TARGET_DIR)/var/lib/cumulocity-agent
    cp -rP $(@D)/lua $(@D)/srtemplate.txt $(@D)/COPYRIGHT $(TARGET_DIR)/usr/share/cumulocity-agent
    sed -e 's#\$$PKG_DIR#/usr/share/cumulocity-agent#g' $(@D)/cumulocity-agent.conf | sed -e 's#\$$DATAPATH#/var/lib/cumulocity-agent#g' > $(TARGET_DIR)/usr/share/cumulocity-agent/cumulocity-agent.conf
    sed 's#$$PREFIX#/usr#g' $(@D)/utils/cumulocity-agent.service > $(TARGET_DIR)/lib/systemd/system/cumulocity-agent.service
    sed 's#$$PREFIX#/usr#g' $(@D)/utils/cumulocity-remoteaccess.service > $(TARGET_DIR)/lib/systemd/system/cumulocity-remoteaccess.service
    touch $(TARGET_DIR)/etc/cumulocity-agent.conf
endef

$(eval $(generic-package))
