ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MDPrefs

MDPrefs_FILES = Tweak.xm \
		im_login.xm \
		im_setting.xm \
		../src/Account.m \
		../src/IMAutoLoginHelper.m


# AutoLogin_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
