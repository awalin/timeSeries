//
//  UsherVizContainer.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UsherTimeseriesViz;
@class UsherTimeSeries;
@class UsherIPADTooltipContent;
//super class for all sorts of visualization
@interface UsherVizContainer : UIView <UIPopoverControllerDelegate>


@property IBOutlet UIView* xAxis;
@property IBOutlet UIView* yAxis;
@property IBOutlet UsherTimeseriesViz* mainViz;

@property UIPopoverController* popOverController;
//@property IBOutlet UIView* legend;


//@property NSMutableDictionary* graphValues;
@property UsherTimeSeries* graphValues;

@property NSMutableDictionary* legends;
@property NSMutableDictionary* yLabels;
@property NSMutableDictionary* xLabels;

@property NSString* vizType;

-(void) setData:(UsherTimeSeries* )data;
-(void) zoomTo:(float)scale  ;
-(void) showTooltip:(UIGestureRecognizer*) sender ;
-(void) adjustYvalues ;
@end
