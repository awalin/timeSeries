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


typedef enum {
    none, // no split, sum of all
    hours,
    days,
    weekdays,
    months,
    quarters,
    departments,
    designations,
    floors
} SplitCategories; // used for splitting / drill down categories

typedef enum {
    point, // no aggregation, point events
    hourly,
    dayly,
    weekly,
    monthly,
    quarterly
} ZoomLevels; // used for aggregating


@property NSMutableDictionary* dataPoints;
@property NSString* title;
@property int aggregation;//zoom level
@property int bins;
@property NSString* categories; //split categories

@property SplitCategories splitBy;
@property ZoomLevels zoomInto;


//key value, key= X position, value= object with label and Y position

-(void) setData:(NSMutableDictionary*)data;
-(void) zoomTo:(float) scale ;
-(void) adjustYscale;
-(void) panView:(CGPoint) translate;
-(void) adjustAnchor:(UIGestureRecognizer*) sender;
-(id) getTouchKey : (UIGestureRecognizer*) sender;

@end
