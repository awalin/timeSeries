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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//-(id) init{
//
//had problem with nib, creates two instance of the uiview, so the one with our assigned valu does not get the property values
//http://stackoverflow.com/questions/2712502/uiview-drawrect-class-variables-out-of-scope

//   id mainview = [[[NSBundle mainBundle] loadNibNamed:@"TimeseriesView"
//                                   owner:self
//                                 options:nil]
//                        objectAtIndex:0];
//
//    //create the frame for the container
//    [self setFrame:CGRectMake(0,
//                              0,
//                              self.frame.size.width,
//                              self.frame.size.height)];
//    return mainview;
//
//}

-(void) setData:(UsherTimeSeries* )data{
    
    self.graphValues = data;
    self.mainViz = [[UsherTimeseriesViz alloc] initWithFrame:CGRectMake(50, 50, 650, 400)];
    [self addSubview:self.mainViz];
    [self.mainViz setData:data.timeSeries];
     //[self setNeedsDisplay];
    
    
}

-(void) zoomTo:(float)scale {

    [self.mainViz zoomTo:scale];

}

-(void) adjustYvalues {
    [self.mainViz adjustYscale];

}

@end
