ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BRMock
BRMock_FILES = Tweak.xm \
	x_io.xm \
	x_mg.xm \
	../src/Device.m \
	../src/NSData+FastHex.m \

ADDITIONAL_CFLAGS += -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk


