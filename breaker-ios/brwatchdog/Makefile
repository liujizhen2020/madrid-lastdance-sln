ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = BRWatchDog
BRWatchDog_FILES = main.mm \
	MaydayChecker.m \
	../src/nk_run_cmd.m \


BRWatchDog_CODESIGN_FLAGS += -SBRWatchDog.plist
BRWatchDog_LDFLAGS = -Wl,-sectcreate,__RESTRICT,__restrict,/dev/null
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN -Wno-module-import-in-extern-c
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk


after-install::
	install.exec "killall -9 BRWatchDog"