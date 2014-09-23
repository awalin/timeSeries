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

@implementation UsherVizContainer



-(void) setData:(UsherTimeSeries* )data{
    
    self.graphValues = data;
    self.mainViz = [[UsherTimeseriesViz alloc] initWithFrame:CGRectMake(50, 50, 650, 400)];
    [self addSubview:self.mainViz];
    [self.mainViz setData:data.timeSeries];
     //[self setNeedsDisplay];
    
    
}

-(void) zoomTo:(float)scale withCenter:(CGPoint) center {

    [self.mainViz zoomTo:scale withCenter:center];

}

-(void) adjustYvalues {
    [self.mainViz adjustYscale];
    
    // now reaggregate if necessary//
    
}

@end
