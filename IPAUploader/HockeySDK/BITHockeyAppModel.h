//
//  AppObject.h
//  IPAUploader
//
//  Created by Francesca Corsini on 09/06/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITHockeyAppModel : NSObject

- (id)initWithJSON:(NSDictionary *)json;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bundleID;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *editDate;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end
