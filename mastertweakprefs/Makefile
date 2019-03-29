DEBUG = 0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MasterTweakPrefs
MasterTweakPrefs_FILES = $(wildcard *.m) 
MasterTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles
MasterTweakPrefs_FRAMEWORKS = UIKit
MasterTweakPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MasterTweakPrefs.plist$(ECHO_END)
