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
#import "UsherIPADTooltipContent.h"

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
    int tot = [(NSArray*)value count];
    NSLog(@"Tooltip Key: %@, Items %d", touchKey, tot);
    double timestamp = 0.0;
    //constrauct the details
    for(id tid in value){
        UsherDataStructure* details = (UsherDataStructure*)[self.graphValues.transactions objectForKey:tid];
        NSLog(@"Transactions: %@  Details: %@, Time %f, %@, User %@", tid, details.transId, details.transTimeStamp, details.weekDay, details.transUserId );
        timestamp =  details.transTimeStamp;
    }
    
    NSDate * date=  [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"dd.MM.yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
            
        UsherIPADTooltipContent* tooltip  = [[UsherIPADTooltipContent alloc] init];
        [tooltip createContent:tot forDate:_date];
        UIPopoverController* aPopover = [[UIPopoverController alloc]
                                         initWithContentViewController:tooltip];
        CGPoint pop = [self.mainViz getTouchPoint:touchKey];
        
        aPopover.delegate = self;
        self.popOverController = aPopover;
        self.popOverController.backgroundColor=[UIColor colorWithRed:0.2 green:0.2 blue:0.22 alpha:0.8];
        [self.popOverController presentPopoverFromRect:CGRectMake(pop.x, pop.y, 1, 1)
                                                    inView: self.mainViz
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
        
    }
    

}

-(void) zoomTo:(float)scale {

    [self.mainViz zoomTo:scale ];

}

-(void) adjustYvalues {
    [self.mainViz adjustYscale];
    
    // now reaggregate if necessary//
    
}

@end
