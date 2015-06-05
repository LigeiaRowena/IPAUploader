//
//  CredentialViewController.h
//  IPAUploader
//
//  Created by Francesca Corsini on 29/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CredentialViewControllerDelegate <NSObject>
- (void)loginFailed:(NSString*)error;
- (void)loginSucceed:(NSString*)message;
@end

@interface CredentialViewController : NSViewController

@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (assign) id <CredentialViewControllerDelegate> delegate;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSButton *rememberButton;

- (void)setupUI;

@end
