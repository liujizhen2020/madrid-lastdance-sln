ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MDMad
MDMad_FILES = Tweak.xm \
	
MDMad_FRAMEWORKS = Security

ADDITIONAL_CFLAGS += -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk

