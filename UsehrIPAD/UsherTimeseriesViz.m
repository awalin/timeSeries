//
//  UsherTimeseriesViz.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherTimeseriesViz.h"



@implementation UsherTimeseriesViz {
    
    UIBezierPath *chart ;
    BOOL zooming;
    NSMutableArray* visibleKeys;
    float scale; // x
    float translation;
    float yScale;
    NSMutableArray* points; // points visible on screen.
    NSMutableArray* focusPoints;
    float eachWidth;
    float max;
    float min;
    float height;
    CAShapeLayer* shapeLayer;
    CAShapeLayer* contextLayer;
    CALayer* axisLayer;
    NSArray* sortedKeys;
    int maxKey; //visible min key
    int minKey; // visible max key
    int pathMin; // included in path
    int pathMax; // included in path
    CGPoint center;
    float contextHeight;
    float axisWidth;
    NSMutableDictionary* allData;
    CALayer* focusLayer;
    int anchorKey;
    int length;//length of points array
    int labelCount;
}


@synthesize title ;
@synthesize dataPoints;



- (void)drawRect:(CGRect)rect {
    
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    [super drawRect:rect];
    
    // Drawing code
    if(!visibleKeys){
        return;
    }
    NSLog(@"draw layers");
    [self drawLayers];
}

-(void) drawShapeLayer {
    
    float x=0.0;
    int i=0;
    //or the max can be the max of the visible values
    for(int  k= minKey ; k<=maxKey; k++){
        id ky= [NSNumber numberWithInt:k];
        x = ([ky intValue]-minKey)*(eachWidth)+ translation;
        //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
        
    }
    
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    chart = [UIBezierPath bezierPath];
    [chart moveToPoint:CGPointMake(point.x, point.y)];
    //creating the path
    for(int j = 1; j<i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    shapeLayer.path = chart.CGPath;
    
}


-(void) highlightFocus {
    
    int focusStart = MAX(minKey, 0);
    float maskStartX = focusStart*(contextLayer.frame.size.width/[dataPoints count]);
    float focusWidth= length* (contextLayer.frame.size.width/[dataPoints count]);
    focusLayer.frame = CGRectMake(maskStartX, 0, focusWidth,contextLayer.frame.size.height);
    
}

-(void) drawYaxis {
    
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(axisWidth-0.5, 0.0)];
    [linePath addLineToPoint:CGPointMake(axisWidth-0.5, height)];
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.opacity = 1.0;
    line.strokeColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:line];
    
    [self drawLabels];
    

    
}

-(void) drawLabels{
    
    //Y-axis lines
    axisLayer.sublayers = nil;
    
    int increament = (max - min)/labelCount;
    NSLog(@"%f %f %d ", min, max, increament);
    float eachHeight = height/labelCount;

    for(int i=0; i <labelCount; i++){
        float x = axisWidth/4;
        float y = height - i*eachHeight;
        CATextLayer* label = [CATextLayer layer];
        [label setAnchorPoint:CGPointMake(0.0, 0.0)];
        label.position = CGPointMake(x,y);
        [label setFrame:CGRectMake(x, y-10, 20, 10)];
        label.foregroundColor = [UIColor blackColor].CGColor;
        label.string = [NSString stringWithFormat:@"%f", min+i*increament];
        //        //        NSLog(@"%@, %f, %f", label.string, label.position.x, label.position.y);
        [label setFontSize:10.0];
        [axisLayer addSublayer:label];
        
    }

    

}


-(void) drawLayers{
    
    int i =0;
    labelCount = 10;
    float x=0.0;
    float widthPerPoint = roundf((shapeLayer.frame.size.width)/([dataPoints count] +1));
    focusPoints = [[NSMutableArray alloc] init];
    //draw context layer
    for(id ky in sortedKeys){
        x = [ky floatValue]*widthPerPoint; // + translation - center.x
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(contextLayer.frame.size.height/max);
        [focusPoints setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
    }
    [focusPoints setObject:[NSValue valueWithCGPoint:CGPointMake(x,contextLayer.frame.size.height)] atIndexedSubscript:i];
    NSValue *val = [focusPoints objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    
    UIBezierPath* chartFocus = [UIBezierPath bezierPath];
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chartFocus moveToPoint:CGPointMake(0.0, contextLayer.frame.size.height)];
    //creating the path
    for(int j = 0; j<=i; j++){
        val = [focusPoints objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chartFocus  addLineToPoint:point];
    }
    [chartFocus closePath];
    contextLayer.path = chartFocus.CGPath;
    
    float maskStartX = minKey*contextLayer.frame.size.width/[dataPoints count];
    float maskEndX = maxKey*contextLayer.frame.size.width/[dataPoints count];
    float focusWidth = maskEndX-maskStartX;
    
    focusLayer.bounds = CGRectMake(maskStartX, 0, focusWidth,contextLayer.frame.size.height);
    focusLayer.anchorPoint = CGPointZero;
    focusLayer.position = CGPointMake(maskStartX,0);
    focusLayer.opacity = 0.4;
    focusLayer.backgroundColor = [UIColor blueColor].CGColor;
    [contextLayer addSublayer:focusLayer];
    [self drawShapeLayer];
   [self drawYaxis];
    
    
}


//first time creation of the data  for the chart
-(void) setData:(NSMutableDictionary*) data {
    
    zooming = NO;
    scale =1.0;
    translation = 0.0;
    contextHeight = 40.0;
    axisWidth = 30.0;
    labelCount = 10;
    
    points = [[NSMutableArray alloc] init];
    dataPoints = [[NSMutableDictionary alloc] init];
    
    title = @"Timeseries data"; // can be used as the title
    center = CGPointMake(0,0);//
    sortedKeys = [[data allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    
    NSLog(@"keys  %d, %d ", minKey, maxKey);
    //chonologically sorting, will be used for visualizing
    for(id ky in sortedKeys){
        int value=[(NSMutableArray*)[data objectForKey:ky] count];
        [dataPoints setObject:[NSNumber numberWithInt:value] forKey: ky];
        
    }
    allData = [[NSMutableDictionary alloc] init];
    allData = data;
    
    shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0.0, 0.0, [self frame].size.width- axisWidth, [self frame].size.height- contextHeight)];
    [shapeLayer setPosition: CGPointMake(([self frame].size.width/2)+axisWidth/2,
                                         ([self frame].size.height-contextHeight)/2)];
    
    height = roundf(shapeLayer.frame.size.height);
    eachWidth = roundf((shapeLayer.bounds.size.width)/([dataPoints count] +1))*scale;
    
    visibleKeys =[[NSMutableArray alloc] init];
    visibleKeys = (NSMutableArray*)sortedKeys ;
    
    self.layer.masksToBounds = YES;
    shapeLayer.masksToBounds = YES; // does not work//
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    pathMin =  minKey;
    pathMax = maxKey;
    anchorKey = minKey;
    
    max = [[[dataPoints allValues] valueForKeyPath: @"@max.self"] floatValue];
    min = [[[dataPoints allValues] valueForKeyPath: @"@min.self"] floatValue];
    
    contextLayer = [CAShapeLayer layer];
    [contextLayer setBounds:CGRectMake(0.0, 0.0, [self frame].size.width-axisWidth, contextHeight )];
    [contextLayer setPosition: CGPointMake((self.frame.size.width/2+axisWidth/2), self.frame.size.height-contextHeight/2)];
    
    UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
    UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
    shapeLayer.strokeColor = lightColor.CGColor;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    contextLayer.fillColor = darkColor.CGColor;
    
    axisLayer = [CALayer layer];
    [axisLayer setBounds:CGRectMake(0.0, 0.0, axisWidth, [self frame].size.height- contextHeight)];
    [axisLayer setPosition: CGPointMake((axisWidth/2),
                                        (self.frame.size.height-contextHeight)/2)];
    focusLayer = [CALayer layer];
    
    [self.layer addSublayer:shapeLayer];
    [self.layer addSublayer:contextLayer];
    [self.layer addSublayer:axisLayer];

    NSLog(@"initial position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    NSLog(@"initial anchor, %f , %f ", shapeLayer.anchorPoint.x, shapeLayer.anchorPoint.y);
    [self setNeedsDisplay];
}


-(void) adjustAnchor:(UIGestureRecognizer*) sender {
     NSLog(@"adjusting anchor");
    //    NSLog(@"old position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    //    NSLog(@"old anchor, %f , %f ", shapeLayer.anchorPoint.x, shapeLayer.anchorPoint.y);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIView *piece = (UIView*)self;
        center  = [sender locationInView:piece]; // new Anchor point
        NSLog(@"center %f", center.x);
        center = CGPointMake(center.x- axisWidth, center.y);
//        NSLog(@"after re adjusting for y-axis center %f", center.x);
    }
    
    
}

-(void) zoomTo:(float) scalez {
    
    if(scalez==1.0) {
        return;
    }
    
    //TODO:zoom should be centered around the touch point
    scale = scalez; // new scale
    NSLog(@"scale %f", scale);
    int oldLength= (int)(shapeLayer.frame.size.width/(eachWidth));
    int newLength = (int)(shapeLayer.frame.size.width/(scale*eachWidth)); // New visible length from currently visible keys
    NSLog(@"old length= %d,  new length %d", oldLength, newLength);
    float anchorPoint = (center.x/shapeLayer.frame.size.width); // considering only scaling, and no pannig
    anchorKey = minKey+(int)((anchorPoint)*oldLength);
    //calculate new min and max keys
    
    int newMinKey = anchorKey - (newLength)*anchorPoint;
    int newMaxKey = anchorKey + (newLength)*(1.0-anchorPoint);
    
    NSLog(@" min key %d", newMinKey);
    NSLog(@" max key %d", newMaxKey);
    NSLog(@" anchor point %f , Key %d", anchorPoint, anchorKey);
    float oldMax = max;
    float oldMin = min;
    
    NSRange visibleRange ;
    visibleRange.location = MAX(0, newMinKey);
    int last = MIN(newMaxKey, [dataPoints count]-1) - visibleRange.location;
    visibleRange.length = last; // length of visible points
    //    // Always create from the super array with all data
    visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:visibleRange] ;
    // now change the y-axis with animation
    
    max = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"] floatValue]; // the new max height
    min = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@min.self"] floatValue]; // the new max height
    
    int p = 0;
    //scale = 'c', anchor point 'a', new point for point x , is: c*x+(1-c)*a//
    for(int i = newMinKey; i<=newMaxKey; i++){
        id ky= [NSNumber numberWithInt:i];
        if([dataPoints objectForKey:ky]!=NULL){
            float x = ([ky intValue]- minKey)*(eachWidth); // old value of x
            x = scale*x + (1-scale)*center.x; // center.x is the anchor point
//            float x = ([ky intValue]- newMinKey)*(eachWidth*scale);
            float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
            [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:p];
            p++;
        }
    }
    // now change the y-axis with animation

    minKey= newMinKey;
    maxKey = newMaxKey;
    eachWidth *= scale;
    length = p;// (maxKey-minKey)
    
    NSLog(@"length %d ", length);
   NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    chart = [UIBezierPath bezierPath];
    [chart moveToPoint:CGPointMake(point.x, point.y)];
    //creating the path
    for(int j = 1; j< length ; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        [chart  addLineToPoint:point];
    }
    shapeLayer.path = chart.CGPath;
    [self highlightFocus];
    
    if(oldMin!=min || oldMax!=max){
        //call adjust y axis-labels
        [self drawLabels];
    }
    
}


-(void) panView:(float) translate{
    
    if(translate==0.0) {
        return;
    }
    NSLog(@"before translation: min = %d,max =  %d", minKey, maxKey);
    translation = -translate;
    int keysInbetween = (int)((fabs(roundf(translation/eachWidth)+0.5)));
//    int totalKeys = (int)(((roundf((fabs(translation)+shapeLayer.frame.size.width)/eachWidth)+0.5)));

    NSLog(@"keys in between %d, translation %f", keysInbetween, translation);
    
    int newMin, newMax;
    if(translation>0 ) { //add new points to the right side of the path, shift left
        NSLog(@"new max ");
        //alternative approach, draw the entire path again//
         newMax = maxKey+keysInbetween; //keep the old min
         newMin = minKey+keysInbetween;
        
    } else if( translation < 0) {
        //add new points to the left side of the path
        
        NSLog(@"new min");
        //alternative approach, draw the entire path again//
        newMin = minKey-keysInbetween; //keep the old min
        newMax = maxKey-keysInbetween;
  }
    
    // now change the y-axis with animation
    float oldMax = max;
    float oldMin = min;
    
    NSRange visibleRange ;
    visibleRange.location = MAX(0, newMin);
    int last = MIN(newMax, [dataPoints count]-1) - visibleRange.location;
    visibleRange.length = last; // length of visible points
    max = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"] floatValue]; // the new max height
    min = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@min.self"] floatValue]; // the new max height
    
    int p = 0;
    //    //scale = 'c', anchor point 'a', new point for point x , is: c*x+(1-c)*a//
        for(int i = newMin; i<=newMax; i++){
            id ky= [NSNumber numberWithInt:i];
            if([dataPoints objectForKey:ky]!=NULL){
            float x = ([ky intValue]- minKey)*(eachWidth) + translation; // old value of x
                float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
                [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:p];
                p++;
            }
        }

  
    minKey= newMin;
    maxKey = newMax;
    length = p;
    NSLog(@"after translation min = %d,max =  %d",  minKey, maxKey);
    
    
    NSLog(@"length %d ", length);
    
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    chart = [UIBezierPath bezierPath];
    [chart moveToPoint:CGPointMake(point.x, point.y)];
    //creating the path
    for(int j = 1; j< length ; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        [chart  addLineToPoint:point];
    }
    shapeLayer.path = chart.CGPath;
    [self highlightFocus];
    
    if(oldMin!=min || oldMax!=max){
        //call adjust y axis-labels
        [self drawLabels];
    }
    

    
   }

-(CGPoint) getTouchPoint :(id)key{
    
    
    id anchor = key;
    float y = (max-[[dataPoints objectForKey:anchor] floatValue])*(height/max);
    float x = ([anchor intValue]-minKey)*(eachWidth)+axisWidth; // old value of x
    return CGPointMake(x,y);
}

-(id) getTouchKey : (UIGestureRecognizer*) sender{
    
    UIView *piece = (UIView*)self;
    CGPoint touch  = [sender locationInView:piece]; // new Anchor point
    touch = CGPointMake(touch.x-axisWidth, touch.y);
    float keys = roundf((touch.x/eachWidth)+0.5); // considering only scaling, and no pannig
    int touchKey = (int)keys + minKey;
    NSLog(@"after re adjusting for y-axis, touch  %f, touch key %d, keys in between %f, min key %d ", touch.x, touchKey, keys, minKey);
    id anchor = [NSNumber numberWithInt:(int)(touchKey)];
    return anchor;
}


//TODO:need to call it after panning, too
-(void) adjustYscale {
    
    return;//
    
    
    
    for(id ky in visibleKeys){
        float x = axisWidth/4; // + translation
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        CAShapeLayer *line2 = [CAShapeLayer layer];
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        [linePath moveToPoint: CGPointMake(0.0, y)];
        [linePath addLineToPoint:CGPointMake(axisWidth, y)];
        line2.path=linePath.CGPath;
        line2.fillColor = nil;
        line2.opacity = 1.0;
        line2.strokeColor = [UIColor blueColor].CGColor;
//        [line addSublayer:line2];
        
        CATextLayer* label = [CATextLayer layer];
        [label setAnchorPoint:CGPointMake(0.0, 0.0)];
        label.position = CGPointMake(x,y);
        [label setFrame:CGRectMake(x, y-10, 20, 10)];
        label.foregroundColor = [UIColor blackColor].CGColor;
        label.string = [NSString stringWithFormat:@"%f",[[dataPoints objectForKey:ky] floatValue]];
        //        NSLog(@"%@, %f, %f", label.string, label.position.x, label.position.y);
        [label setFontSize:10.0];
        [axisLayer addSublayer:label];
        
    }
    

    
    
    
    
//    NSRange visibleRange ;
//    visibleRange.location = MAX(0,minKey);
//    int last = MIN([dataPoints count]-1, maxKey);
//    visibleRange.length = length;
//    //    // Always create from the super array with all data
//    visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:visibleRange] ;
//    // now change the y-axis with animation
//    float cmax = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"] floatValue]; // the new max height
    
//    {
//        max= cmax;
//        int i = 0;
//        float x=0.0;
//        for(id ky in visibleKeys){ // as opposed to visible keys
//            x = [ky floatValue]*eachWidth;
//            //         NSLog(@"keys: %f, position %f ", [ky floatValue], x);
//            float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
//            [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
//            i++;
//        }
//    [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,height)] atIndexedSubscript:i];//may need to replace with another more appropriate oint to close the path
//        
//
//        
//        NSValue *val = [points objectAtIndex:0];
//        CGPoint point = [val CGPointValue];
//        
//        chart = [UIBezierPath bezierPath];
//        [chart moveToPoint:CGPointMake(0.0, height)];
//        //creating the path
//        for(int j = 0; j<=i; j++){
//            val = [points objectAtIndex:j];
//            point = [val CGPointValue];
//            //        NSLog(@"x: %f, y %f ", point.x, point.y);
//            [chart  addLineToPoint:point];
//        }
//        [chart closePath];
//        
//        //animate path to new value
//        CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"path"];
//        [animatePath setFromValue: (id)shapeLayer.path];
//        [animatePath setToValue: (id)chart.CGPath];
//        [animatePath setDuration:1.0];
//        
//        [shapeLayer addAnimation:animatePath forKey:nil];
//        shapeLayer.path = chart.CGPath;
        
        
//    } else {
//        //same max height, no change needed
//        return;
//    }
    //path creation done, now add this path as the path of the shape layer
    
    
}

-(void) zoomLaternate{
    
    /*
     NSMutableArray* newPoints = [[NSMutableArray alloc] init];
     //zoom out, new points may be added
     if(newMinKey<minKey){
     for(int i = newMinKey; i<minKey; i++){
     id ky= [NSNumber numberWithInt:i];
     float x = ([ky intValue]- minKey)*(eachWidth); // old value of x
     x = scale*x + (1-scale)*center.x; // center.x is the anchor point
     //NSLog(@"keys: %d, position %f ", [ky intValue], x);
     float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
     [newPoints setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:p];
     p++;
     }
     }
     
     if((oldLength>newLength)){
     //zoom in, no new point will be added
     
     for(int i = newMinKey; i< newMaxKey; i++){
     id ky= [NSNumber numberWithInt:i];
     float x = ([ky intValue]- minKey)*(eachWidth); // old value of x
     x = scale*x + (1-scale)*center.x; // center.x is the anchor point
     //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
     float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
     [newPoints setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:p];
     p++;
     
     }
     }
     if(newMaxKey<maxKey){
     //zoom out, new points may be added
     for(int i = maxKey; i< newMaxKey; i++){
     
     id ky= [NSNumber numberWithInt:i];
     float x = ([ky intValue]- minKey)*(eachWidth); // old value of x
     x = scale*x + (1-scale)*center.x; // center.x is the anchor point
     //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
     float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
     [newPoints setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:p];
     p++;
     }
     }
     
     */
}

@end
