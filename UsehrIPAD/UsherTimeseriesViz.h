//
//  UsherTimeseriesViz.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

//#import "UsherVizContainer.h"
#import <QuartzCore/QuartzCore.h>

@interface UsherTimeseriesViz : UIView


@property NSMutableDictionary* dataPoints;
@property NSString* title;
//key value, key= X position, value= object with label and Y position

-(void) setData:(NSMutableDictionary*)data;
//-(id) initWithData:(NSMutableDictionary*) data;

@end
