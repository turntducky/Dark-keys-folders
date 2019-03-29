FINALPACKAGE = 1
ARCHS = arm64 arm64e
THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MasterTweak
MasterTweak_FILES = $(wildcard *.xm) $(wildcard *.m)
MasterTweak_FRAMEWORKS = UIKit CoreGraphics
MasterTweak_CFlags = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += MasterTweakPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 Preferences"

after-stage::
	find . -name ".DS_Store" -delete
