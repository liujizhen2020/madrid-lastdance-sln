ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BRAlert
BRAlert_FILES = Tweak.xm \
	../src/Account.m \
	PasscodeManager.m \
	x_alert.xm \
	 
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard && killall -9 Preferences"