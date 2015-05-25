//
//  AppDelegate.m
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "AppDelegate.h"
#import "BITHockeyManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // app id taken from the App detail in hockeyapp
    // ex: Speedy W-BE
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:[[BITHockeyManager sharedHockeyManager] getAppIdentifier]];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    [[BITHockeyManager sharedHockeyManager] testIdentifier];
    
    // add a contentView
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.window.contentView addSubview:self.viewController.view];
    self.viewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
