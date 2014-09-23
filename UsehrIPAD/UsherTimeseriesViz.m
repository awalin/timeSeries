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
    float scale;
    NSMutableArray* points;
    float eachWidth;
    float max;
    float height;
    CAShapeLayer* shapeLayer;
    NSArray* sortedKeys;
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
    
    
    //SOPAN:
    NSLog(@"draw layers");
    //    NSLog(@"%@",dataPoints);
    //Drawing starts
    height = rect.size.height;
    eachWidth = rect.size.width/([dataPoints count] +1);
    
    //     NSLog(@"visible keys %d", count);
    
    //     NSLog(@"max = %d, each width %f ", [max intValue], eachWidth);
    int i = 0;
    float x=0.0;
    for(id ky in [[dataPoints allKeys] sortedArrayUsingSelector: @selector(compare:)]){
        x = [ky floatValue]*eachWidth*scale;
        //         NSLog(@"keys: %f, position %f ", [ky floatValue], x);
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
    //chonologically sorting, will be used for visualizing
    for(id ky in sortedKeys){
        int value=[(NSMutableArray*)[data objectForKey:ky] count];
        [dataPoints setObject:[NSNumber numberWithInt:value] forKey: ky];
        
    }
    visibleKeys =[[NSMutableArray alloc] init];
    visibleKeys = (NSMutableArray*)sortedKeys ;
    
    self.layer.masksToBounds = YES;
    
    max = [[[dataPoints allValues] valueForKeyPath: @"@max.self"] floatValue];
    [self.layer addSublayer:shapeLayer];
    
    [self setNeedsDisplay];
}

-(void) adjustAnchor:(CGPoint) anchor {
    
    NSLog(@"adjusting anchor");
    
    shapeLayer.anchorPoint = CGPointMake(anchor.x / shapeLayer.bounds.size.width, shapeLayer.anchorPoint.y);
    
}

-(void) zoomTo:(float) scalez withCenter:(CGPoint) center{
    //TODO:zoom should be centered around the touch point
    
    zooming = YES;
    scale = scalez;
    NSRange theRange;
       NSLog(@"scale %f", scale);
    
    //Center the zooming around the pinch point
    
    int visiblePoints = (int)(self.layer.frame.size.width/(eachWidth*scale));
    NSLog(@"visible points %d", visiblePoints);
    if(visiblePoints<3){
        return;
    }
    else if(visiblePoints <= [dataPoints count]){
        theRange.length = (int)(roundf(visiblePoints-0.5))-1; // considering scale = 2
        //        NSLog(@"%d, %d", theRange.length, [visibleKeys count]);
        int midvalue = (int)(roundf(center.x/(eachWidth*scale)-0.5));
       
        theRange.location = midvalue-theRange.length/2;
        NSLog(@"%d, %d", theRange.length, theRange.location);
        

        visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:theRange ] ;
        
        NSArray* exisitngpoints= [dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] ;
        NSLog(@"%@", exisitngpoints);
        if([exisitngpoints count]<3){
            NSLog(@"Too few markers");
            return;
        }
        
        CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animatePath setFromValue: [NSValue valueWithCATransform3D:CATransform3DScale(shapeLayer.transform, 1.0, 1.0, 1.0) ]];
        [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0) ]];
        [animatePath setDuration:1.0];
        
        [shapeLayer addAnimation:animatePath forKey:nil];
        shapeLayer.transform = CATransform3DScale(shapeLayer.transform, scale, 1.0, 1.0);
        NSLog(@"zooming");
        

        
    //    [self setNeedsDisplay];
        } else {
        NSLog(@"doing nothing %d, scale %f ", visiblePoints, scalez );
        scalez = 1.0;
        return;
    }
//
    
    
    
    
}


-(void) panView:(CGPoint) translate{
    NSLog(@"translating view ");
    
    //    CGPoint center = [shapeLayer position];
    //    NSLog(@"%f %f, trans %f , %f ", shapeLayer.position.x, shapeLayer.position.y, translate.x, translate.y );
    //    [shapeLayer setPosition:CGPointMake(center.x+translate.x*0.5, center.y)];
    
    CABasicAnimation *animatePath = [CABasicAnimation animationWithKeyPath:@"transform.translate"];
    [animatePath setFromValue: [NSValue valueWithCATransform3D:CATransform3DTranslate(shapeLayer.transform, 0.0, 0.0, 0.0) ]];
    [animatePath setToValue:   [NSValue valueWithCATransform3D:CATransform3DTranslate(shapeLayer.transform, translate.x*0.2, 0.0, 0.0) ]];
    [animatePath setDuration:0.2];
    
    [shapeLayer addAnimation:animatePath forKey:nil];
    shapeLayer.transform = CATransform3DTranslate(shapeLayer.transform, translate.x*0.2, 0.0, 0.0);
    
    
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
