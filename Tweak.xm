#import <Foundation/Foundation.h>

static NSString* const kMasterTweaksettings = @"/var/mobile/Library/Preferences/com.ducksrepo.mastertweak.plist";

static NSMutableDictionary *settings;

static BOOL Enabledarkkeyboard = NO;
static BOOL Enabledarkfolders = NO;

void refreshPrefs()
{
    [settings release];
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ducksrepo.mastertweak.plist"];
	Enabledarkkeyboard = [settings objectForKey:@"darkkeyboard"] ? [[settings objectForKey:@"darkkeyboard"] boolValue] : YES;
	Enabledarkfolders = [settings objectForKey:@"darkfolders"] ? [[settings objectForKey:@"darkfolders"] boolValue] : YES;

//Dark iOS keyboard (system wide)
%group darkkeyboard
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
	if([[settings objectForKey:@"darkkeyboard"] boolValue] == YES ){
		%orig(NO);
	} else {%orig(YES); }
}
%end

%hook UIDevice
- (long long)_keyboardGraphicsQuality {
	if([[settings objectForKey:@"darkkeyboard"] boolValue] == YES ){
		return 10;
	} else {return 100; }
}
%end
%end
//End Dark Keyboard

//Enables Dark Folders
%group darkfolders
@interface SBIconBlurryBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView (SBIconBlurryBackgroundView)
@end

@interface SBFolderBackgroundView (UIView)
@end

%hook SBFolderBackgroundView
- (void)layoutSubviews {
  %orig;

  if([[settings objectForKey:@"darkfolders"] boolValue] == YES ){
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIVisualEffectView* folderBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    MSHookIvar<UIVisualEffectView*>(self, "_blurView") = folderBackgroundView;
    [MSHookIvar<UIVisualEffectView*>(self, "_blurView") setFrame:self.bounds];
    [self addSubview:folderBackgroundView];
  }
}
%end

%hook SBFolderIconBackgroundView
- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
  if([[settings objectForKey:@"darkfolders"] boolValue] == YES ){
  	%orig(CGRectNull, nil, nil);
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
  } else {
    %orig;
  }
}
%end
%end
//End enabling of Dark Folders

%ctor {
    @autoreleasepool {
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[kMasterTweaksettings stringByExpandingTildeInPath]];

		if(settings == NULL)
		{
			// If preferences plist does not exist, create it with default settings
			settings = [@{
			@"darkkeyboard" : @FALSE,
			@"darkfolders" : @FALSE
			
			} mutableCopy];
		}
	if([[settings objectForKey:@"darkkeyboard"] boolValue])
	{
	// Only init hooks if the tweak has actually been set to enabled.
	 CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.ducksrepo.mastertweak.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	 refreshPrefs();
	%init(darkkeyboard);
	}
	if([[settings objectForKey:@"darkfolders"] boolValue])
	{
	// Only init hooks if the tweak has actually been set to enabled.
	 CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.ducksrepo.mastertweak.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	 refreshPrefs();
	%init(darkfolders);
	}
    }
}
