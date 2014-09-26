//
//  UsherVizContainer.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherVizContainer.h"
#import "UsherTimeSeriesViz.h"
#import "UsherTimeSeries.h"
#import "UsherDataStructure.h"

@implementation UsherVizContainer



-(void) setData:(UsherTimeSeries* )data{
    
    self.graphValues = data;
    self.mainViz = [[UsherTimeseriesViz alloc] initWithFrame:CGRectMake(50, 50, 650, 440)];
    [self addSubview:self.mainViz];
    [self.mainViz setData:data.timeSeries];
    
     //[self setNeedsDisplay];
    
    
}

-(void) showTooltip:(UIGestureRecognizer*) sender {
    
    
    id touchKey = [self.mainViz getTouchKey :sender ];
    id value = [self.graphValues.timeSeries objectForKey:touchKey];

//    NSLog(@"Tooltip Key: %@ %@", touchKey, value );
    
    for(id tid in value){
        
         UsherDataStructure* details = (UsherDataStructure*)[self.graphValues.transactions objectForKey:tid];
         NSLog(@"Transactions: %@  Details: %@, Time %f, %@, User %@", tid, details.transId, details.transTimeStamp, details.weekDay, details.transUserId );
   }
 // detect the point, return the key
    // construct the valuse here
    //send them to viz to render the tooltip
    

}

-(void) zoomTo:(float)scale {

    [self.mainViz zoomTo:scale ];

}

-(void) adjustYvalues {
    [self.mainViz adjustYscale];
    
    // now reaggregate if necessary//
    
}

@end
