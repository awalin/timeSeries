//
//  UsherDataStructure.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/8/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsherDataStructure : NSObject

@property NSString *transId;
@property NSDate *transDate;
@property NSTimeInterval transTimeStamp;
@property NSString *month;
@property NSString *weekDay;
@property NSString *week;
@property NSString *year;
@property NSString *transType;
@property NSString *transUserId;
@property NSString *success;

-(UsherDataStructure*) createDataObject:(NSArray *) fromFile;

@end
