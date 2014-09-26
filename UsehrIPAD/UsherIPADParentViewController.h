//
//  UsherIPADParentViewController.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UsherTimeSeries.h"
#import "UsherVizContainer.h"
@class UsherIPADTooltipContent;

@interface UsherIPADParentViewController : UIViewController <UIPopoverControllerDelegate>


@property UsherVizContainer* timeseriesView;
@property UIPopoverController* popOverController;

@end
