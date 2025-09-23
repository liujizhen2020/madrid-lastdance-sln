ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MDSys
MDSys_FILES = Tweak.xm \
	x_sysv.xm \

ADDITIONAL_CFLAGS += -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk


