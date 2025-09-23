#import <Foundation/Foundation.h>

%hook FTPasswordManager

- (void)cleanUpAccountsBasedOnInUseUsernames:(id)arg1 profileIDs:(id)arg2 completionBlock:(id /* block */)arg3{
	NSLog(@" 🍅 🍅 🍅 %@", NSStringFromSelector(_cmd));
    NSLog(@" 🍅 🍅 🍅 usernames %@", arg1);
    NSLog(@" 🍅 🍅 🍅 profileIDs %@", arg2);
    %orig;
}

%end
