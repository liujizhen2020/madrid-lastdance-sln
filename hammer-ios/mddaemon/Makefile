ARCHS = arm64
# SDKVERSION = 15.6

include $(THEOS)/makefiles/common.mk

TOOL_NAME = MDDaemon
MDDaemon_FILES = main.mm \
	Daemon.m \
	handyman.m \
	x_ak_ssl.m \
	../src/Device.m \
	../src/BinaryCert.m \
	../src/ServerAPI.m \
	../src/Account.m \
	../src/dec.m \
	../src/nk_run_cmd.m \
	../src/NKSessionManager.m \
	../src/dump.m \
	../src/keychain.m \
	../src/NSData+FastHex.m \
	../src/IMAutoLoginHelper+Caller.m \
	../src/IMAutoLoginHelper.m \

MDDaemon_CODESIGN_FLAGS += -SMDDaemon.plist

MDDaemon_LDFLAGS = -Wl,-sectcreate,__RESTRICT,__restrict,/dev/null -lsqlite3 -lMobileGestalt
MDDaemon_FRAMEWORKS += Accounts Security
MDDaemon_PRIVATE_FRAMEWORKS += SpringBoardServices MobileActivation AppleIDAuthSupport AuthKit FTServices IDS Message MIME AppleAccount

ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN -Wno-module-import-in-extern-c
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk

after-install::
	install.exec "killall -9 MDDaemon"