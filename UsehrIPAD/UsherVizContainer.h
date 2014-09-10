//
//  UsherVizContainer.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsherVizContainer : UIView

@property NSString* vizType;
@property UIView* xAxis;
@property UIView* yAxis;
@property UIView* mainViz;
@property NSMutableArray* dataToDisplay;
@property UIGestureRecognizer* gestureRecognizer;

@end
