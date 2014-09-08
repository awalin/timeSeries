//
//  UsherDataStructure.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/8/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherDataStructure.h"

@implementation UsherDataStructure

-(UsherDataStructure*) createDataObject:(NSArray *) fromFile{
    
        
        [self setTransId:[fromFile objectAtIndex:0]];
        [self setTransType:[fromFile objectAtIndex:2]];
        [self setSuccess:[fromFile objectAtIndex:4]];
        [self setWeekDay:[fromFile objectAtIndex:13]];
        [self setMonth:[fromFile objectAtIndex:14] ];
    
        self.month =  [[self.month componentsSeparatedByString:@" "] objectAtIndex:1];
    
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\" "];
        self.weekDay = [[self.weekDay componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    
    
    
        [self setYear:[fromFile objectAtIndex:15]];
        self.year = [[self.year componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"MM/dd/yy HH:mm"];
    NSString *stringTime = [fromFile objectAtIndex:16];
    NSDate *dateTime = [formatter dateFromString:stringTime];
    
    [self setTransDate:dateTime];
    [self setTransTimeStamp: [self.transDate timeIntervalSince1970]];
    
//    NSLog(@":%@,%@,%@,%f,%@", self.month, self.year, self.weekDay, self.transTimeStamp, self.transDate);
    
    return self;
}

@end
