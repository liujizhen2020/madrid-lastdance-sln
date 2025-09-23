//
//  AppDelegate.m
//  MadridExpresss
//
//  Created by yt on 15/07/22.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import <dlfcn.h>

static void load_mac_library(void);

@interface AppDelegate ()

@property (strong, nonatomic) MainWindowController *mainVC;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    load_mac_library();
    
    self.mainVC  = [[MainWindowController alloc] initWithWindowNibName:NSStringFromClass([MainWindowController class])];
    [self.mainVC.window makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

void load_mac_library() {
    dlopen("/System/Library/PrivateFrameworks/IMFoundation.framework/Versions/A/IMFoundation", RTLD_NOW);
    dlopen("/System/Library/PrivateFrameworks/FTServices.framework/Versions/A/FTServices", RTLD_NOW);
}


@end
