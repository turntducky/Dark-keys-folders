#import <Foundation/Foundation.h>

static NSString *nsDomainString = @"com.ducksrepo.mastertweakprefs";
static NSString *nsNotificationString = @"com.ducksrepo.mastertweak/preferences.changed";

static BOOL darkkeyboard;
static BOOL darkfolders;

@interface NSUserDefaults (MasterTweak)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
@interface FBSystemService : NSObject
+(id)sharedInstance;
-(void)exitAndRelaunch:(BOOL)arg1;
@end
@interface SpringBoard : NSObject
- (void)_relaunchSpringBoardNow;
+(id)sharedInstance;
-(id)_accessibilityFrontMostApplication;
-(void)clearMenuButtonTimer;
@end

//Dark iOS keyboard (system wide)
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
	if(darkkeyboard){
	    %orig(NO);
	} else {
	    %orig(light); //could either be YES or NO
	}
}
%end

%hook UIDevice
- (long long)_keyboardGraphicsQuality {
	if(darkkeyboard){
           return 10;
	} else {
	   return %orig; 
	}
}
%end
//End Dark Keyboard

//Enables Dark Folders
@interface SBIconBlurryBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end

@interface SBFolderBackgroundView : UIView
@end

%hook SBFolderIconBackgroundView

- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
		if(darkfolders) {
		%orig(CGRectNull, NULL, NULL);

    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
	} else {%orig;}
}

%end

%hook SBFolderBackgroundView

- (void)layoutSubviews {
        %orig;
	if(darkfolders){

    UIView *tintView = [self valueForKey:@"_tintView"];
    tintView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
	}
}

%end
//End enabling of Dark Folders

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

	NSNumber* k = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"darkkeyboard" inDomain:nsDomainString];
	NSNumber* df = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"darkfolders" inDomain:nsDomainString];

	darkkeyboard = (k) ? [k boolValue] : NO;
	darkfolders = (df) ? [df boolValue] : NO;

static void respring() {
	SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
  	if ([sb respondsToSelector:@selector(_relaunchSpringBoardNow)]) {
    	[sb _relaunchSpringBoardNow];
  	} else if (%c(FBSystemService)) {
    	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
  	}
}

%ctor {
	notificationCallback(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		notificationCallback,
		(CFStringRef)nsNotificationString,
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, CFSTR("com.ducksrepo.mastertweak/respring"), NULL, 0);
}
