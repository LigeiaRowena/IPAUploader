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
#import "FTPClient.h"
#import "NSScrollView+MultiLine.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Init

- (void)loadView
{
    [super loadView];
    
    // create a popover
    CredentialViewController *credentialViewController = [[CredentialViewController alloc] initWithNibName:@"CredentialViewController" bundle:nil];
    credentialViewController.delegate = self;
    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = credentialViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - CredentialViewControllerDelegate

- (void)loginFailed
{
    [self.popover performClose:self.loginButton];
}

- (void)loginSucceed:(NSString*)message
{
    [self.popover performClose:self.loginButton];
    [self.loginStatus setStringValue:message];
}

#pragma mark - IRTextFieldDragDelegate

- (void)performDragOperation:(NSString*)text
{
    [self.ipaField setStringValue:text];
}

#pragma mark - Popover Login

- (void)showPopover:(id)sender
{
    [self.popover showRelativeToRect:self.loginButton.bounds ofView:self.loginButton preferredEdge:NSMinYEdge];
}

- (void)closePopover:(id)sender
{
    [self.popover performClose:sender];
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    if (self.popover.shown)
        [self closePopover:sender];
    else
        [self showPopover:sender];
}

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

- (IBAction)uploadHockeyApp:(id)sender
{
    [self.progressBar startAnimation:nil];
    
    NSString *token = [[BITHockeyManager sharedHockeyManager] getToken];
    if (token == nil)
    {
        [self showAlertOfKind:NSCriticalAlertStyle WithTitle:@"Warning" AndMessage:@"You have to login to your HockeyApp account"];
        return;
    }
    
    [BITHockeyManager uploadApp:self.ipaField.stringValue releaseNotes:[self.releaseNotes getStringValue] token:@"" withBlock:^(id response, NSError *error) {
        NSLog(@"---uploadApp %@", response);
        if (!response || error)
            [self showAlertOfKind:NSCriticalAlertStyle WithTitle:@"Warning" AndMessage:@"The upload of the file you selected failed: please try again"];
        else
            [self showAlertOfKind:NSInformationalAlertStyle WithTitle:@"Information" AndMessage:@"The upload of the file you selected finished successfully"];
        [self.progressBar stopAnimation:nil];
    }progressBlock:^(NSProgress *pr) {
        NSString *progress = [NSString stringWithFormat:@"Progress: %@ (%lli of %lli bytes)", pr.localizedDescription, pr.completedUnitCount, pr.totalUnitCount];
        [self.progressLabel setStringValue:progress];
    }];
}

- (IBAction)uploadFTP:(id)sender
{
    [self.progressBar startAnimation:nil];

    [FTPClient uploadApp:self.ipaField.stringValue releaseNotes:[self.releaseNotes getStringValue] withBlock:^(id response, NSError *error) {
        NSLog(@"---uploadApp %@", response);
        if (!response || error)
            [self showAlertOfKind:NSCriticalAlertStyle WithTitle:@"Warning" AndMessage:@"The upload of the file you selected failed: please try again"];
        else
            [self showAlertOfKind:NSInformationalAlertStyle WithTitle:@"Information" AndMessage:@"The upload of the file you selected finished successfully"];
        [self.progressBar stopAnimation:nil];
    }progressBlock:^(NSProgress *pr) {
        NSString *progress = [NSString stringWithFormat:@"Progress: %@ (%lli of %lli bytes)", pr.localizedDescription, pr.completedUnitCount, pr.totalUnitCount];
        [self.progressLabel setStringValue:progress];
    }];
}

#pragma mark - Alert Methods

- (void)showAlertOfKind:(NSAlertStyle)style WithTitle:(NSString *)title AndMessage:(NSString *)message
{
    // Show a critical alert
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:style];
    [alert runModal];
}


@end
