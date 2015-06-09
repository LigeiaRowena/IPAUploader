//
//  ViewController.h
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IRTextFieldDrag.h"
#import "CredentialViewController.h"
#import "AppsWindowController.h"

@interface ViewController : NSViewController <IRTextFieldDragDelegate, CredentialViewControllerDelegate, NSPopoverDelegate>

@property (weak) IBOutlet IRTextFieldDrag *ipaField;
@property (weak) IBOutlet NSProgressIndicator *progressBarUpload;
@property (weak) IBOutlet NSProgressIndicator *progressBarGetInfo;
@property (weak) IBOutlet NSScrollView *releaseNotes;
@property (weak) IBOutlet NSTextField *progressLabel;
@property (strong, nonatomic) NSPopover *popover;
@property (weak) IBOutlet NSTextField *loginStatus;
@property (weak) IBOutlet NSButton *loginButton;
@property (strong, nonatomic) AppsWindowController *appsWindowController;

@end
