//
//  AppDelegate.h
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) ViewController *viewController;
@property (weak) IBOutlet NSWindow *window;

@end

