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
    float eachWidth;
    float max;
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
    for(int  k=minKey ; k< maxKey; k++){
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
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chart moveToPoint:CGPointMake(0.0, height)];
    //creating the path
    for(int j = 0; j<i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    shapeLayer.path = chart.CGPath;
    
}


-(void) highlightFocus {

    float maskStartX = minKey*contextLayer.frame.size.width/[dataPoints count];
    float maskEndX = maxKey*contextLayer.frame.size.width/[dataPoints count];
    float focusWidth = maskEndX-maskStartX;
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
    line.strokeColor = [UIColor blueColor].CGColor;
    [axisLayer addSublayer:line];
    
    //Y-axis lines
    
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
        [line addSublayer:line2];
        
        CATextLayer* label = [CATextLayer layer];
        [label setAnchorPoint:CGPointMake(0.0, 0.0)];
        label.position = CGPointMake(x,y);
        [label setFrame:CGRectMake(x, y-10, 20, 10)];
        label.foregroundColor = [UIColor blackColor].CGColor;
//        label.string = [NSString stringWithFormat:@"%f",[[dataPoints objectForKey:ky] floatValue]];
//        NSLog(@"%@, %f, %f", label.string, label.position.x, label.position.y);
        [label setFontSize:10.0];
        [line addSublayer:label];
        
    }


}

-(void) drawLayers{
    
    
    int i =0;
    float x=0.0;
    float widthPerPoint = roundf((shapeLayer.frame.size.width)/([dataPoints count] +1));
    
    //draw context layer
    for(id ky in sortedKeys){
        x = [ky floatValue]*widthPerPoint; // + translation - center.x
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(contextLayer.frame.size.height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
    }
   [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,contextLayer.frame.size.height)] atIndexedSubscript:i];
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    
    chart = [UIBezierPath bezierPath];
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chart moveToPoint:CGPointMake(0.0, contextLayer.frame.size.height)];
    //creating the path
    for(int j = 0; j<=i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    [chart closePath];
    contextLayer.path = chart.CGPath;
    
    
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
    
//    [self drawLayers];
   
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
        NSLog(@"after re adjusting for y-axis center %f", center.x);
    }
    
    
}

-(void) zoomTo:(float) scalez {
    
    //TODO:zoom should be centered around the touch point
   
    zooming = YES;
    scale = scalez; // new scale

    int oldLength= (int)(shapeLayer.frame.size.width/(eachWidth));;
    int newLength = (int)(shapeLayer.frame.size.width/(scale*eachWidth)); // New visible length from currently visible keys
    float anchorPoint = (center.x/shapeLayer.frame.size.width); // considering only scaling, and no pannig
    anchorKey = minKey+(int)((anchorPoint)*oldLength);
    
    int newMinKey = anchorKey-(center.x-0.0)/(eachWidth*scale);
    NSLog(@"alternate min key %d", newMinKey);

    int newMaxKey= newMinKey+(shapeLayer.frame.size.width)/(eachWidth*scale);
    NSLog(@"alternate max key %d", newMaxKey);
    
    //calculate new min and max keys
//    int newMinKey = anchorKey - (newLength)*anchorPoint;
//    int newMaxKey = anchorKey + (newLength)*(1.0-anchorPoint);
    
    NSLog(@"scale %f,new min %d, new max %d", scale, newMinKey, newMaxKey);
    
    if(newMinKey<0) {
        newMinKey = 0;
    }

    if(newMaxKey > ([dataPoints count]-1)){
        newMaxKey = [dataPoints count]-1;
    }
    
//    int startIndex = newMinKey, endIndex = newMaxKey;
//    eachWidth *= scale;
//    int p = 0;
    
    //scale = 'c', anchor point 'a', new point for point x , is: c*x+(1-c)*a//
      for(int i = newMinKey; i<= newMaxKey; i++){
        id ky= [NSNumber numberWithInt:i];
        float x = ([ky intValue]- minKey)*(eachWidth); // old value of x
        x = scale*x + (1-scale)*center.x; // center.x is the anchor point
        //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
//        p++;
    }
    
    
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
    
    
    
    NSLog(@"old length= %d,  new length %d", oldLength, newLength);
        
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
        
    chart = [UIBezierPath bezierPath];
        //    [chart setLineJoinStyle:kCALineJoinRound];
        [chart moveToPoint:CGPointMake(0.0, height)];
        //creating the path
    for(int j = 0; j< newLength; j++){
            val = [points objectAtIndex:j];
            point = [val CGPointValue];
            //        NSLog(@"x: %f, y %f ", point.x, point.y);
            [chart  addLineToPoint:point];
        }
    
    
    shapeLayer.path = chart.CGPath;
    minKey= newMinKey;
    maxKey = newMaxKey;
    eachWidth *= scale;
    
//    [self drawShapeLayer];

}


-(void) panView:(float) translate{
  
    NSLog(@"before translation: min = %d,max =  %d", minKey, maxKey);
    translation = -translate;
    int keysInbetween = (int)((fabs(translation/eachWidth)));
    NSLog(@"keys in between %d, translation %f", keysInbetween, translation);
//    int totalKeys = (int)((shapeLayer.bounds.size.width+fabs(translation))/eachWidth);//previous visible keys+ keysinbetween, roughly

    if(translation>0 && keysInbetween>0) { //add new points to the right side of the path, shoft left
        NSLog(@"new max ");
        //alternative approach, draw the entire path again//
        int newMax = maxKey+keysInbetween; //keep the old min
        float x=0.0;
        int endkey = MIN(newMax,[dataPoints count]-1);
        
        chart = [UIBezierPath bezierPath];
        id ky = [NSNumber numberWithInt:minKey]; // what if there is no such keys?
        //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        [chart  moveToPoint:CGPointMake(0,y)];
        
        //or the max can be the max of the visible values
        for(int  k = minKey ; k<= endkey; k++){
            id ky = [NSNumber numberWithInt:k]; // what if there is no such keys?
            x = ([ky intValue]-minKey)*(eachWidth);
            //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
            float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
            [chart  addLineToPoint:CGPointMake(x,y)];
        }
        shapeLayer.path = chart.CGPath;
        maxKey = endkey;//MIN(newMax,[dataPoints count]-1);
        minKey = minKey+ keysInbetween;
       
        if(minKey<0) {
            minKey = 0;
        }
        
        NSLog(@"after translation min = %d,max =  %d",  minKey, maxKey);
      
   } else if( translation < 0 && keysInbetween>0) { //add new points to the right side of the path
            //add new points to the right side of the path, shoft left
        NSLog(@"new min");
        //alternative approach, draw the entire path again//
        int newMin = minKey-keysInbetween; //keep the old min
        float x=0.0;
        chart = [UIBezierPath bezierPath];
        int startkey = MAX(newMin,0);
       
        id ky = [NSNumber numberWithInt:startkey]; // what if there is no such keys?
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        [chart  moveToPoint:CGPointMake(0,y)];

        //    [chart setLineJoinStyle:kCALineJoinRound];
        [chart moveToPoint:CGPointMake(0.0, height)];
        //or the max can be the max of the visible values
        for(int k = startkey; k<= maxKey; k++){
                id ky= [NSNumber numberWithInt:k];//what if there is no such keys ?
                x = ([ky intValue]- newMin)*(eachWidth);
                //            NSLog(@"keys: %d, position %f ", [ky intValue], x);
                float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
                [chart  addLineToPoint:CGPointMake(x,y)];
        }

        shapeLayer.path = chart.CGPath;
        minKey = startkey;
        maxKey = maxKey-keysInbetween;
        
        if(maxKey > ([dataPoints count])-1){
            maxKey = [dataPoints count]-1;
        }
        NSLog(@"after translation min = %d,max =  %d",  minKey, maxKey);
        
   }

    
    //    NSLog(@"translating view ");
//    CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform"];
//    [animatePath setFromValue: [NSValue valueWithCATransform3D:shapeLayer.transform]];//identity or shapeLayer.transform
//    [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DTranslate(shapeLayer.transform, translation, 0.0, 0.0) ]];
//    [animatePath setDuration:0.2];
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
    shapeLayer.transform = CATransform3DTranslate(shapeLayer.transform, -translation, 0.0, 0.0);
//    [CATransaction commit];
//    [shapeLayer addAnimation:animatePath forKey:nil];
    
    
    [self highlightFocus];
    
    //    NSLog(@"new position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    
}

-(id) getTouchKey : (UIGestureRecognizer*) sender{
        UIView *piece = (UIView*)self;
        center  = [sender locationInView:piece]; // new Anchor point
        NSLog(@"center %f", center.x);
        center = CGPointMake(center.x- axisWidth, center.y);
        NSLog(@"after re adjusting fro y-axis center %f", center.x);
        float anchorData = (center.x/shapeLayer.bounds.size.width)*[dataPoints count]; // considering only scaling, and no pannig
        id anchorKey = [NSNumber numberWithInt:(int)(anchorData)];
//        id allValue = [allData objectForKey:anchorKey];
//        NSLog(@"anchor data point value: %@, for key: %@", allValue, anchorKey);
    
    return anchorKey;


}
    
    
-(void) visibleData {
//    float visible = 100.00/scale;
//    int visibleLength = (int)(roundf([dataPoints count]*1.00/scale));
//    float anchorData = (center.x/shapeLayer.bounds.size.width)*[dataPoints count]; // considering only scaling, and no pannig
//    id anchorKey = [NSNumber numberWithInt:(int)(anchorData)];
//    id value = [dataPoints objectForKey:anchorKey];
//    id allValue = [allData objectForKey:anchorKey];
//    NSLog(@"anchor data point value: %@, for key: %@", allValue, anchorKey);
    
}

//TODO:need to call it after panning, too
-(void) adjustYscale {
    
    return;//
    
    NSRange visibleRange ;
    visibleRange.location = minKey;
    visibleRange.length = maxKey-minKey;
    //    // Always create from the super array with all data
    visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:visibleRange] ;
    
    
    // now change the y-axis with animation
    float cmax = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"] floatValue]; // the new max height
    if(cmax!=max){
        int i = 0;
        float x=0.0;
        for(id ky in visibleKeys){ // as opposed to visible keys
            x = [ky floatValue]*eachWidth;
            //         NSLog(@"keys: %f, position %f ", [ky floatValue], x);
            float y = (cmax-[[dataPoints objectForKey:ky] floatValue])*(height/cmax);
            [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
            i++;
        }
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,height)] atIndexedSubscript:i];//may need to replace with another more appropriate oint to close the path
        
        max= cmax;
        
        NSValue *val = [points objectAtIndex:0];
        CGPoint point = [val CGPointValue];
        
        chart = [UIBezierPath bezierPath];
        [chart moveToPoint:CGPointMake(0.0, height)];
        //creating the path
        for(int j = 0; j<=i; j++){
            val = [points objectAtIndex:j];
            point = [val CGPointValue];
            //        NSLog(@"x: %f, y %f ", point.x, point.y);
            [chart  addLineToPoint:point];
        }
        [chart closePath];
        
        //animate path to new value
        CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"path"];
        [animatePath setFromValue: (id)shapeLayer.path];
        [animatePath setToValue: (id)chart.CGPath];
        [animatePath setDuration:1.0];
        
        [shapeLayer addAnimation:animatePath forKey:nil];
        shapeLayer.path = chart.CGPath;
        
        
    } else {
        //same max height, no change needed
        return;
    }
    //path creation done, now add this path as the path of the shape layer
    
    
}

@end
