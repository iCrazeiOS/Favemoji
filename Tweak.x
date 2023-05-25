#import <UIKit/UIKit.h>

@interface EMFEmojiToken
@property (nonatomic, copy) NSString *string;
+(instancetype)emojiTokenWithString:(NSString *)string localeData:(id)date;
@end

static NSMutableDictionary *prefs;
BOOL enabled = YES;
NSString *emojis = @"";


// Override the recent emojis
%hook EMFEmojiPreferences
-(NSArray *)recentEmojis {
	if (!enabled) return %orig;

	NSMutableArray<EMFEmojiToken *> *newEmojis = [NSMutableArray array];
	for (int i = 0; i < [emojis length]; i++) {
		NSString *emojiString = [emojis substringWithRange:[emojis rangeOfComposedCharacterSequenceAtIndex:i]];

		// Create the EMFEmojiToken
		EMFEmojiToken *emoji = [%c(EMFEmojiToken) emojiTokenWithString:emojiString localeData:nil];

		// Fixes emojis being added twice
		if (![[newEmojis lastObject].string isEqualToString:emojiString]) {
			[newEmojis addObject:emoji];
		}
	}
	return [newEmojis copy];
}

+(NSArray *)_recentEmojiStrings {
	if (!enabled) return %orig;

	NSMutableArray *newStrings = [NSMutableArray array];
	for (int i = 0; i < [emojis length]; i++) {
		NSString *emojiString = [emojis substringWithRange:[emojis rangeOfComposedCharacterSequenceAtIndex:i]];

		// Must match the recentEmojis array
		if (![[newStrings lastObject] isEqualToString:emojiString]) {
			[newStrings addObject:emojiString];
		}
	}
	return [newStrings copy];
}

%end


// Stop iOS from updating the recent emojis
%hook EMFEmojiPreferencesClient
-(void)writeEmojiDefaults {
	if (!enabled) %orig;
}
-(void)didUseEmoji:(id)arg1 {
	if (!enabled) %orig;
}
-(void)didUseEmoji:(id)arg1 usageMode:(id)arg2 {
	if (!enabled) %orig;
}
-(void)didUseEmoji:(id)arg1 usageMode:(id)arg2 typingName:(id)arg3 {
	if (!enabled) %orig;
}
%end


// Rename the "Frequently Used" category
%hook UIKeyboardEmojiCategory
+(NSString *)displayName:(long long)arg1 {
	return (enabled && arg1 == 0) ? @"Favourites" : %orig;
}
%end


static void loadPrefs() {
	NSString *path = @"/var/mobile/Library/Preferences/com.icraze.favemoji.plist";
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/var/mobile/Library/Preferences/"]) {
		path = [@"/var/jb" stringByAppendingString:path];
	}
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

	enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	emojis = (prefs[@"emojis"] == nil) ? @"" : prefs[@"emojis"];

	// Remove spaces in case the user added them
	emojis = [emojis stringByReplacingOccurrencesOfString:@" " withString:@""];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.favemoji.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
