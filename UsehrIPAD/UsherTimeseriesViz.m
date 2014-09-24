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
    NSArray* sortedKeys;
    int maxKey; //visible min key
    int minKey; // visible max key
    CGPoint center;
}


@synthesize title ;
@synthesize dataPoints;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.*/
//+ (Class) layerClass {
//    return [CAShapeLayer class];
//}
//
//
//- (CAShapeLayer *) shapeLayer
//{
//    return (CAShapeLayer *)self.layer;
//}


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
        x = [ky floatValue]*eachWidth*scale + translation; // + translation
//        NSLog(@"keys: %d, position %f ", [ky intValue], x);
        float y = (max-[[dataPoints objectForKey:ky] floatValue])*(height/max);
        [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
        i++;
    }
    [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,height)] atIndexedSubscript:i];
    
    NSValue *val = [points objectAtIndex:0];
    CGPoint point = [val CGPointValue];
    
    chart = [UIBezierPath bezierPath];
    //    [chart setLineJoinStyle:kCALineJoinRound];
    [chart moveToPoint:CGPointMake(0.0, height)];
    //creating the path
    for(int j = 0; j<=i; j++){
        val = [points objectAtIndex:j];
        point = [val CGPointValue];
        //        NSLog(@"x: %f, y %f ", point.x, point.y);
        [chart  addLineToPoint:point];
    }
    [chart closePath];
    shapeLayer.path = chart.CGPath;

}


//first time creation of the data  for the chart
-(void) setData:(NSMutableDictionary*) data {
    
    zooming = NO;
    scale =1.0;
    translation = 0.0;
    shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0.0, 0.0, [self frame].size.width, [self frame].size.height )];
    [shapeLayer setPosition: CGPointMake(self.frame.size.width/2,
                                         self.frame.size.height/2)];
   
    //    UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
    UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
    shapeLayer.fillColor = lightColor.CGColor;
    //    self.shapeLayer.strokeColor = darkColor.CGColor;
    
    points = [[NSMutableArray alloc] init];
    dataPoints = [[NSMutableDictionary alloc] init];
    title = @"Timeseries data"; // can be used as the title
    
    sortedKeys = [[data allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    
    NSLog(@"keys  %d, %d ", minKey, maxKey);
    //chonologically sorting, will be used for visualizing
    for(id ky in sortedKeys){
        int value=[(NSMutableArray*)[data objectForKey:ky] count];
        [dataPoints setObject:[NSNumber numberWithInt:value] forKey: ky];
        
    }
    visibleKeys =[[NSMutableArray alloc] init];
    visibleKeys = (NSMutableArray*)sortedKeys ;
    
    self.layer.masksToBounds = YES;
    
    height = roundf(self.layer.frame.size.height);
    eachWidth = roundf(self.layer.frame.size.width/([dataPoints count] +1));
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    
    
    max = [[[dataPoints allValues] valueForKeyPath: @"@max.self"] floatValue];
    [self.layer addSublayer:shapeLayer];
    [self drawShapeLayer];
//    [self setNeedsDisplay];
}


-(void) adjustAnchor:(UIGestureRecognizer*) sender {
    NSLog(@"adjusting anchor");
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIView *piece = (UIView*)self;
        center  = [sender locationInView:piece];
        NSLog(@"adjusting anchor, %f , %f ", center.x, center.y);
        CGPoint locationInSuperview = [sender locationInView:(UIView*)self.superview];
        shapeLayer.anchorPoint = CGPointMake(center.x / shapeLayer.bounds.size.width, shapeLayer.anchorPoint.y);
        shapeLayer.position = CGPointMake(locationInSuperview.x, shapeLayer.position.y);
    }
    
    
//    shapeLayer.anchorPoint = CGPointMake(anchor.x / shapeLayer.bounds.size.width, shapeLayer.anchorPoint.y);
  
}

-(void) zoomTo:(float) scalez {
    //TODO:zoom should be centered around the touch point
    
    zooming = YES;
    scale = scalez;
    NSRange theRange;
//    NSLog(@"scale %f", scale);
//    eachWidth *=scale;
    //Center the zooming around the pinch point
    
    minKey = [[sortedKeys objectAtIndex:0] intValue];
    maxKey = [[sortedKeys objectAtIndex:[sortedKeys count]-1] intValue];
    
    int visiblePoints = (int)(self.layer.frame.size.width/(eachWidth*scale));
//    NSLog(@"visible points %d", visiblePoints);
    
//    shapeLayer.transform;
    
//    if(visiblePoints <= [dataPoints count])
    {
        theRange.length = (int)(roundf(visiblePoints-0.5))-1; // considering scale = 2
        //        NSLog(@"%d, %d", theRange.length, [visibleKeys count]);
        int midvalue = (int)(roundf(center.x/(eachWidth*scale)-0.5));
       
        theRange.location = MAX(0, (int)(midvalue-theRange.length/2));
        int last = MIN([dataPoints count]-1, theRange.location+theRange.length);
        theRange.length= last-theRange.location; // +1 ?
        
//        NSLog(@"%d, %d,  %d", theRange.length, midvalue, theRange.location);
        
        visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:theRange ] ;
        
        CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animatePath setFromValue: [NSValue valueWithCATransform3D:shapeLayer.transform]];
        [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0) ]];
        [animatePath setDuration:0.25];
        [CATransaction begin]; // this removes the jittering effect
        [CATransaction setDisableActions:YES];
        shapeLayer.transform = CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0);
        [CATransaction commit];
        [shapeLayer addAnimation:animatePath forKey:nil];
//        NSLog(@"zooming");

        }
//    else {
//            NSLog(@"doing nothing %d, scale %f ", visiblePoints, scalez );
//            scalez = 1.0;
//            return;
//    }
//
    
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
        
    } else {
        return;
    }
    //path creation done, now add this path as the path of the shape layer
    
    
}

@end
