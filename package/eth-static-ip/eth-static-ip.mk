################################################################################
#
# eth-static-ip 
#
################################################################################

ETH_STATIC_IP_VERSION = 1.0
ETH_STATIC_IP_SITE = $(BR2_EXTERNAL_SOFTWAREAG_PATH)/package/eth-static-ip
ETH_STATIC_IP_SITE_METHOD = local

define ETH_STATIC_IP_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0600 $(@D)/eth-static-ip.nmconnection $(TARGET_DIR)/etc/NetworkManager/system-connections
endef

$(eval $(generic-package))
