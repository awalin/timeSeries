//
//  UsherTimeSeries.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/9/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsherTimeSeries : NSObject


//typedef enum {
//    point, // no aggregation, point events
//    hourly,
//    dayly,
//    weekly,
//    monthly,
//    quarterly
//} AggregateLevel; // used for aggregating


@property NSMutableDictionary *timeSeries;
@property (strong) NSMutableArray  *transactions;
@property double min;
@property double max;
@property int aggregation;//zoom level
@property int bins;
//@property AggregateLevel aggregateBy;
@property NSArray* months;
@property NSArray* weekdays;




@end
