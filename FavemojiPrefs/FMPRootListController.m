#import "FMPRootListController.h"

@implementation FMPRootListController
-(NSString *)plistPathForFilename:(NSString *)filename {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/var/mobile/Library/Preferences/"]) {
		path = [@"/var/jb" stringByAppendingString:path];
	}
	return path;
}

-(id)readPreferenceValue:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
}

-(NSArray *)specifiers {
	if (!_specifiers) _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	return _specifiers;
}

-(void)loadView {
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
}

-(void)respring {
	// Dismiss keyboard and wait a second before respringing
	// Make sure the field is saved before respringing
	[self.view endEditing:YES];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		pid_t pid;
		const char* args[] = {"sbreload", NULL, NULL};
		posix_spawn(&pid, ROOT_PATH("/usr/bin/sbreload"), NULL, NULL, (char* const*)args, NULL);
	});
}
@end
