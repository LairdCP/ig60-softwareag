################################################################################
#
# ig-rs485
#
################################################################################

IG_RS485_VERSION = 1.0
IG_RS485_SITE = $(BR2_EXTERNAL_SOFTWAREAG_PATH)/package/ig-rs485
IG_RS485_SITE_METHOD = local

define IG_RS485_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/set-ttyS2-rs485.py $(TARGET_DIR)/usr/bin/set-ttyS2-rs485.py
endef

define IG_RS485_INSTALL_INIT_SYSTEMD
    $(INSTALL) -D -m 0644 $(@D)/set-ttyS2-rs485.service $(TARGET_DIR)/etc/systemd/system/set-ttyS2-rs485.service
    $(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
    ln -rsf $(TARGET_DIR)/etc/systemd/system/set-ttyS2-rs485.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/set-ttyS2-rs485.service
endef

$(eval $(generic-package))
