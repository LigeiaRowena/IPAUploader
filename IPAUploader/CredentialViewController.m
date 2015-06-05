//
//  CredentialViewController.m
//  IPAUploader
//
//  Created by Francesca Corsini on 29/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "CredentialViewController.h"
#import "BITHockeyManager.h"
#import "SettingsHandler.h"

@interface CredentialViewController ()

@end

@implementation CredentialViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setupUI
{
    //detect if the app has to remember credentials
    if ([SettingsHandler rememberCredentials])
    {
        self.username.stringValue = [SettingsHandler getUsername];
        self.password.stringValue = [SettingsHandler getPassword];
        self.rememberButton.state = NSOnState;
    }
    else
    {
        self.username.stringValue = @"";
        self.password.stringValue = @"";
        self.rememberButton.state = NSOffState;
    }
}

#pragma mark - Actions

- (IBAction)tapRememberButton:(id)sender
{
    // remember credentials ON
    if (self.rememberButton.state == NSOnState)
    {
        [SettingsHandler setRememberCredentials:YES];
    }
    
    // remember credentials OFF
    else if (self.rememberButton.state == NSOffState)
    {
        [SettingsHandler setRememberCredentials:NO];
    }
}

- (IBAction)login:(id)sender
{
    [self.progress startAnimation:nil];

    if (self.username != nil && self.password != nil)
    {
        [BITHockeyManager loginWithEmail:self.username.stringValue password:self.password.stringValue block:^(id response, NSError *error) {
            if (error == nil && response != nil)
            {
                NSString *token = response[@"tokens"][0][@"token"];
                [[BITHockeyManager sharedHockeyManager] setToken:token];
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginSucceed:)])
                    [self.delegate loginSucceed:[NSString stringWithFormat:@"Login successfully with email: %@\n Token: %@", self.username.stringValue, token]];
                
                if ([SettingsHandler rememberCredentials])
                {
                    [SettingsHandler setUsername:self.username.stringValue];
                    [SettingsHandler setPassword:self.password.stringValue];
                    [SettingsHandler setToken:token];
                }
            }
            else
            {
                [self.username setStringValue:@""];
                [self.password setStringValue:@""];
                [SettingsHandler setUsername:self.username.stringValue];
                [SettingsHandler setPassword:self.password.stringValue];
                [SettingsHandler setToken:@""];
                [SettingsHandler setRememberCredentials:NO];
                self.rememberButton.state = NSOffState;
                [[BITHockeyManager sharedHockeyManager] setToken:@""];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailed:)])
                    [self.delegate loginFailed:[NSString stringWithFormat:@"Login failed with error: %@", error.localizedDescription]];
            }
           
            [self.progress stopAnimation:nil];
        }];
    }
    else
    {        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailed:)])
            [self.delegate loginFailed:@"Please insert a correct username and password in order to login"];
        [self.progress stopAnimation:nil];
    }
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