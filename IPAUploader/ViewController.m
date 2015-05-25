//
//  ViewController.m
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BITHockeyManager.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IRTextFieldDragDelegate

- (void)performDragOperation:(NSString*)text
{
    
}

#pragma mark - Actions

- (IBAction)browseIPAFile:(id)sender
{
    // resign as first responder the other controls
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    [appDelegate.window makeFirstResponder: nil];
    
    // Browse the IPA file
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"ipa", @"IPA"]];
    
    if ([openDlg runModal] == NSOKButton)
    {
        NSString* fileNameOpened = [[[openDlg URLs] objectAtIndex:0] path];
        [self.ipaField setStringValue:fileNameOpened];
    }
}

- (IBAction)upload:(id)sender
{
    [self.progressBar startAnimation:nil];
    
    
    /*
    NSDictionary *headers = @{@"X-HockeyAppToken" : @"769d1e8f260e48b8a3972f803f14842f"};
    [BITHockeyManager get:@"https://rink.hockeyapp.net/api/2/apps" headers:headers parameters:nil withBlock:^(id response, NSError *error) {
        NSLog(@"response %@", response);
    }];
     */
    
    
    
    [BITHockeyManager uploadApp:self.ipaField.stringValue withBlock:^(id response, NSError *error) {
        NSLog(@"---uploadApp %@", response);
        [self.progressBar stopAnimation:nil];
    }];
}

@end
