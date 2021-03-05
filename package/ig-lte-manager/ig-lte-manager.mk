################################################################################
#
# ig-lte-manager
#
################################################################################

IG_LTE_MANAGER_VERSION = 1.0
IG_LTE_MANAGER_SITE = $(BR2_EXTERNAL_SOFTWAREAG_PATH)/package/ig-lte-manager
IG_LTE_MANAGER_SITE_METHOD = local

define IG_LTE_MANAGER_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/lte_manager.py $(TARGET_DIR)/usr/bin/lte_manager.py
    $(INSTALL) -D -m 0600 $(@D)/iglte.nmconnection $(TARGET_DIR)/etc/NetworkManager/system-connections
endef

define IG_LTE_MANAGER_INSTALL_INIT_SYSTEMD
    $(INSTALL) -D -m 0644 $(@D)/lte_manager.service $(TARGET_DIR)/etc/systemd/system/lte_manager.service
    $(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
    ln -rsf $(TARGET_DIR)/etc/systemd/system/lte_manager.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/lte_manager.service
endef

$(eval $(generic-package))
