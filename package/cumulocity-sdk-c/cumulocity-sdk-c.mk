################################################################################
#
# cumulocity-sdk-c
#
################################################################################

CUMULOCITY_SDK_C_VERSION = v2.7
CUMULOCITY_SDK_C_SITE = https://bitbucket.org/m2m/cumulocity-sdk-c.git
CUMULOCITY_SDK_C_SITE_METHOD = git
CUMULOCITY_SDK_C_GIT_SUBMODULES = YES
#CUMULOCITY_SDK_C_SOURCE = cumulocity-sdk-c
CUMULOCITY_SDK_C_DEPENDENCIES = lua libcurl
CUMULOCITY_SDK_C_INSTALL_STAGING = YES
CUMULOCITY_SDK_C_LICENSE = MIT
CUMULOCITY_SDK_C_LICENSE_FILES = COPYRIGHT

define CUMULOCITY_SDK_C_CONFIGURE_CMDS
    cp $(@D)/Makefile.template $(@D)/Makefile
endef

define CUMULOCITY_SDK_C_BUILD_CMDS
    $(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) release
endef

define CUMULOCITY_SDK_C_INSTALL_STAGING_CMDS
    $(INSTALL) -D -m 0644 $(@D)/include/*.h $(STAGING_DIR)/usr/include
    $(INSTALL) -D -m 0644 $(@D)/ext/pahomqtt/MQTTPacket/src/*.h $(STAGING_DIR)/usr/include
    $(INSTALL) -D -m 0644 $(@D)/ext/LuaBridge/Source/LuaBridge/*.h $(STAGING_DIR)/usr/include
    mkdir -p $(STAGING_DIR)/usr/include/detail
    $(INSTALL) -D -m 0644 $(@D)/ext/LuaBridge/Source/LuaBridge/detail/*.h $(STAGING_DIR)/usr/include/detail
    $(INSTALL) -D -m 0755 $(@D)/lib/libsera.so.1.2.7 $(STAGING_DIR)/usr/lib
    ln -srf $(STAGING_DIR)/usr/lib/libsera.so.1.2.7 $(STAGING_DIR)/usr/lib/libsera.so.1
    ln -srf $(STAGING_DIR)/usr/lib/libsera.so.1 $(STAGING_DIR)/usr/lib/libsera.so
endef

define CUMULOCITY_SDK_C_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/lib/libsera.so.1.2.7 $(TARGET_DIR)/usr/lib
    ln -srf $(TARGET_DIR)/usr/lib/libsera.so.1.2.7 $(TARGET_DIR)/usr/lib/libsera.so.1
    ln -srf $(TARGET_DIR)/usr/lib/libsera.so.1 $(TARGET_DIR)/usr/lib/libsera.so
    $(INSTALL) -D -m 0755 $(@D)/bin/srwatchdogd $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
