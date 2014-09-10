//
//  UsherVizContainer.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <UIKit/UIKit.h>
//super class for all sorts of visualization
@interface UsherVizContainer : UIView


@property IBOutlet UIView* xAxis;
@property IBOutlet UIView* yAxis;
@property IBOutlet UIView* mainViz;
@property IBOutlet UIView* legend;

@property NSString* vizType;
@property NSMutableArray* dataToDisplay;
@property UIGestureRecognizer* gestureRecognizer;

@end
