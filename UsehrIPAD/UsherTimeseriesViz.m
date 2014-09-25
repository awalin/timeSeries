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
    NSMutableArray* points;
    float eachWidth;
    float max;
    float height;
    CAShapeLayer* shapeLayer;
    CAShapeLayer* contextLayer;
    CALayer* axisLayer;
    NSArray* sortedKeys;
    int maxKey; //visible min key
    int minKey; // visible max key
    CGPoint center;
    float contextHeight;
    float axisWidth;
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
    //    [self drawShapeLayer];
}

-(void) drawShapeLayer{
    
    int i = 0;
    float x=0.0;
    
    for(id ky in sortedKeys){
        x = [ky floatValue]*(eachWidth*scale); // + translation - center.x
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(shapeLayer.bounds.size.height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
    }
    [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,shapeLayer.bounds.size.height)] atIndexedSubscript:i];
    
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    
    chart = [UIBezierPath bezierPath];
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chart moveToPoint:CGPointMake(0.0, shapeLayer.bounds.size.height)];
    //creating the path
    for(int j = 0; j<=i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    [chart closePath];
    shapeLayer.path = chart.CGPath;
   

    
    i =0;
    for(id ky in sortedKeys){
        x = [ky floatValue]*(eachWidth*scale); // + translation - center.x
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(contextLayer.bounds.size.height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
    }
    [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,contextLayer.bounds.size.height)] atIndexedSubscript:i];
    val = [points objectAtIndex:0];
    point = [val CGPointValue];
    
    chart = [UIBezierPath bezierPath];
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chart moveToPoint:CGPointMake(0.0, contextLayer.bounds.size.height)];
    //creating the path
    for(int j = 0; j<=i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    [chart closePath];
    contextLayer.path = chart.CGPath;
    
    
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(axisWidth/2, 0.0)];
    [linePath addLineToPoint:CGPointMake(axisWidth/2, height)];
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.opacity = 1.0;
    line.strokeColor = [UIColor blueColor].CGColor;
    [axisLayer addSublayer:line];
    
    
    for(id ky in sortedKeys){
//        float x = axisWidth/2; // + translation
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

//        CATextLayer* label = [CATextLayer layer];
//        label.position = CGPointMake(x,y);
//        label.anchorPoint = CGPointMake(0.5,0.5);
//        label.foregroundColor = [UIColor blackColor].CGColor;
//        label.string = [NSString stringWithFormat:@"%f",[[dataPoints objectForKey:ky] floatValue]];
//        NSLog(@"%@, %f, %f", label.string, label.position.x, label.position.y);
//        [label setFontSize:10.0];
//        [line addSublayer:label];
        
    }

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

    
    shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0.0, 0.0, [self frame].size.width- axisWidth, [self frame].size.height- contextHeight)];
    [shapeLayer setPosition: CGPointMake(([self frame].size.width/2)+axisWidth/2,
                                         ([self frame].size.height-contextHeight)/2)];
    height = roundf(shapeLayer.frame.size.height);
    eachWidth = roundf((shapeLayer.bounds.size.width)/([dataPoints count] +1));
    
    visibleKeys =[[NSMutableArray alloc] init];
    visibleKeys = (NSMutableArray*)sortedKeys ;
    
    self.layer.masksToBounds = YES;
    shapeLayer.masksToBounds = YES; // does not work//
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    max = [[[dataPoints allValues] valueForKeyPath: @"@max.self"] floatValue];
    
    contextLayer = [CAShapeLayer layer];
    [contextLayer setBounds:CGRectMake(0.0, 0.0, [self frame].size.width-axisWidth, contextHeight )];
    [contextLayer setPosition: CGPointMake((self.frame.size.width/2+axisWidth/2), self.frame.size.height-contextHeight/2)];
    
    UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
    UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
    shapeLayer.fillColor = lightColor.CGColor;
    contextLayer.fillColor = darkColor.CGColor;
    
    axisLayer = [CALayer layer];
    [axisLayer setBounds:CGRectMake(0.0, 0.0, axisWidth, [self frame].size.height- contextHeight)];
    [axisLayer setPosition: CGPointMake((axisWidth/2),
                                         (self.frame.size.height-contextHeight)/2)];
//    axisLayer.backgroundColor = [UIColor grayColor].CGColor;
    
    [self.layer addSublayer:shapeLayer];
    [self.layer addSublayer:contextLayer];
    [self.layer addSublayer:axisLayer];
    
    [self drawShapeLayer];
   
   
    NSLog(@"initial position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    NSLog(@"initial anchor, %f , %f ", shapeLayer.anchorPoint.x, shapeLayer.anchorPoint.y);
    //    [self setNeedsDisplay];
}


-(void) adjustAnchor:(UIGestureRecognizer*) sender {
    
    
    NSLog(@"adjusting anchor");
    NSLog(@"old position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    NSLog(@"old anchor, %f , %f ", shapeLayer.anchorPoint.x, shapeLayer.anchorPoint.y);
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIView *piece = (UIView*)self;
        center  = [sender locationInView:piece]; // new Anchor point
        NSLog(@"center %f", center.x);
       
        float newAnchorX = center.x/(shapeLayer.bounds.size.width); // *scale?
        float oldPointX  = shapeLayer.anchorPoint.x*shapeLayer.bounds.size.width;
        float centerX = center.x;//* scale; //apply transfor
        oldPointX = oldPointX;//*scale; // apply transform
        float positionX = shapeLayer.position.x;
        positionX -= oldPointX;
        positionX += centerX;
        
        shapeLayer.anchorPoint = CGPointMake(newAnchorX ,  shapeLayer.anchorPoint.y);
        shapeLayer.position = CGPointMake(positionX, shapeLayer.position.y);
        //        CGPoint locationInSuperview = [sender locationInView:(UIView*)self.superview];
        //        NSLog(@"new location in super , %f , %f ", locationInSuperview.x, locationInSuperview.y);
        
        NSLog(@"new anchor, %f , %f ", shapeLayer.anchorPoint.x, shapeLayer.anchorPoint.y);
        NSLog(@"new position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    }
    
    
}

-(void) zoomTo:(float) scalez {
    
    
    //TODO:zoom should be centered around the touch point
   
    zooming = YES;
    
    scale = scalez; // new scale
    CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animatePath setFromValue: [NSValue valueWithCATransform3D:shapeLayer.transform]];
    [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0) ]];
    [animatePath setDuration:0.25];
    [CATransaction begin]; // this removes the jittering effect
    [CATransaction setDisableActions:YES];
    shapeLayer.transform = CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0);
    [CATransaction commit];
    [shapeLayer addAnimation:animatePath forKey:nil];
    
    
}


-(void) panView:(CGPoint) translate{
    //    NSLog(@"translating view ");
    CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animatePath setFromValue: [NSValue valueWithCATransform3D:shapeLayer.transform]];//identity or shapeLayer.transform
    [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DTranslate(shapeLayer.transform, translate.x*0.2, 0.0, 0.0) ]];
    [animatePath setDuration:0.2];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    shapeLayer.transform = CATransform3DTranslate(shapeLayer.transform, translate.x*0.2, 0.0, 0.0);
    [CATransaction commit];
    [shapeLayer addAnimation:animatePath forKey:nil];
    
    //    NSLog(@"new position, %f , %f ", shapeLayer.position.x, shapeLayer.position.y);
    
}



//TODO:need to call it after panning, too
-(void) adjustYscale {
    return;
    
    
    
    // now change the y-axis with animation
    float cmax = [[[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"] floatValue];
    if(cmax!=max){
        
        
        int i = 0;
        float x=0.0;
        for(id ky in sortedKeys){ // as opposed to visible keys
            x = [ky floatValue]*eachWidth*scale;
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
        
        
        
        //    visibleKeys = [[NSMutableArray alloc] init];
        //
        //    int kc = (int)(maxKey - (shapeLayer.bounds.size.width-center.x)*(maxKey-minKey)/shapeLayer.bounds.size.width);
        //
        //    NSLog(@"anchor key %d", kc);
        //    float lastX=0.0;
        //
        //    for(id ky in sortedKeys){
        //        x = ([ky intValue]-kc)*(eachWidth*scale); // + translation
        //        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        //        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        //
        //        if(x>=0.0 && x<= shapeLayer.bounds.size.width) {
        //            [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        //            [visibleKeys setObject:ky atIndexedSubscript:i];
        //            i++;
        //            lastX = x;
        //        }
        //    }
        //    [points setObject:[NSValue valueWithCGPoint:CGPointMake(lastX,height)] atIndexedSubscript:i];
        //    visibleKeys = (NSMutableArray*)[visibleKeys sortedArrayUsingSelector: @selector(compare:)];
        //    minKey = [[visibleKeys objectAtIndex:0] intValue];
        //    maxKey = [[visibleKeys objectAtIndex:[visibleKeys count]-1] intValue];
        //
        //   NSLog(@"keys  %d, %d ", minKey, maxKey);
        //
        //    NSValue *val = [points objectAtIndex:0];
        //    CGPoint point = [val CGPointValue];
        //
        //    chart = [UIBezierPath bezierPath];
        //    //    [chart setLineJoinStyle:kCALineJoinRound];
        //    [chart moveToPoint:CGPointMake(0.0, height)];
        //    //creating the path
        //    for(int j = 0; j<=i; j++){
        //        val = [points objectAtIndex:j];
        //        point = [val CGPointValue];
        //        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        //        [chart  addLineToPoint:point];
        //    }
        //    [chart closePath];
        
        
        
        //        theRange.length = (int)(roundf(visiblePoints-0.5))-1; // considering scale = 2
        //        //        NSLog(@"%d, %d", theRange.length, [visibleKeys count]);
        //        int midvalue = (int)(roundf(center.x/(eachWidth*scale)-0.5));
        //
        //        theRange.location = MAX(0, (int)(midvalue-theRange.length/2));
        //        int last = MIN([dataPoints count]-1, theRange.location+theRange.length);
        //        theRange.length= last-theRange.location; // +1 ?
        //
        ////        NSLog(@"%d, %d,  %d", theRange.length, midvalue, theRange.location);
        //
        //        visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:theRange ] ;
        
        
        
    } else {
        return;
    }
    //path creation done, now add this path as the path of the shape layer
    
    
}

@end
