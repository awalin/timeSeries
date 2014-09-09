//
//  UsherTimeSeries.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/9/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsherTimeSeries : NSObject


@property NSMutableDictionary *timeSeries;
@property (strong) NSMutableArray  *transactions;
@property double min;
@property double max;



@end
