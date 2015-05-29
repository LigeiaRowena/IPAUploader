//
//  CredentialViewController.m
//  IPAUploader
//
//  Created by Francesca Corsini on 29/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "CredentialViewController.h"
#import "BITHockeyManager.h"

@interface CredentialViewController ()

@end

@implementation CredentialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
/*
    self.username.stringValue = @"francesca.corsini@wuerth-phoenix.com";
    self.password.stringValue = @"Objectivec9";
 */
}

- (IBAction)login:(id)sender
{
    if (self.username != nil && self.password != nil)
    {
        [BITHockeyManager loginWithEmail:self.username.stringValue password:self.password.stringValue block:^(id response, NSError *error) {
            NSString *token = response[@"tokens"][0][@"token"];
            [[BITHockeyManager sharedHockeyManager] setToken:token];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginSucceed:)])
                [self.delegate loginSucceed:[NSString stringWithFormat:@"Login successfully with email: %@", self.username.stringValue]];
        }];
    }
    else
    {
        [self showAlertOfKind:NSCriticalAlertStyle WithTitle:@"Warning" AndMessage:@"Please insert a correct username and password in order to login"];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailed)])
            [self.delegate loginFailed];
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