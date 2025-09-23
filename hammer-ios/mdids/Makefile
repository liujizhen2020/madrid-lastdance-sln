ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MDIds
MDIds_FILES = Tweak.xm \
	x_ft_noclean.xm \
	x_ids.xm \
	../src/Account.m \
	../src/Device.m \

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 identityservicesd"
