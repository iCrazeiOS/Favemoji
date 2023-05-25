include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FavemojiPrefs
FavemojiPrefs_FILES = FMPRootListController.m
FavemojiPrefs_INSTALL_PATH = /Library/PreferenceBundles
FavemojiPrefs_FRAMEWORKS = UIKit
FavemojiPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FavemojiPrefs.plist$(ECHO_END)
