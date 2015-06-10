//
//  AppObject.m
//  IPAUploader
//
//  Created by Francesca Corsini on 09/06/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "BITHockeyAppModel.h"

@implementation BITHockeyAppModel

- (id)initWithJSON:(NSDictionary *)json
{
	self = [super init];
	if (self) {
		
		self.formatter = [[NSDateFormatter alloc] init];
		self.formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
		
		self.name = json[@"title"];
		self.bundleID = json[@"bundle_identifier"];
		self.creationDate = [self.formatter dateFromString:json[@"created_at"]];
		if (json[@"updated_at"])
			self.editDate = [self.formatter dateFromString:json[@"updated_at"]];
		else if (json[@"integrated_at"])
			self.editDate = [self.formatter dateFromString:json[@"integrated_at"]];
	}
	return self;
}

@end
