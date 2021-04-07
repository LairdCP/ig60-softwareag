################################################################################
#
# rogers-config
#
################################################################################

ROGERS_CONFIG_VERSION = 1.0
ROGERS_CONFIG_SITE = $(BR2_EXTERNAL_SOFTWAREAG_PATH)/package/rogers-config
ROGERS_CONFIG_SITE_METHOD = local
ROGERS_CONFIG_DEPENDENCIES = cumulocity-agent

define ROGERS_CONFIG_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0644 $(@D)/cumulocity-agent-rogers.conf $(TARGET_DIR)/usr/share/cumulocity-agent/cumulocity-agent.conf
endef

$(eval $(generic-package))
