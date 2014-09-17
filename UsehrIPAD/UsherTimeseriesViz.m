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
}


@synthesize title ;
@synthesize dataPoints;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.*/
+ (Class) layerClass {
    return [CAShapeLayer class];
}


- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}


 - (void)drawRect:(CGRect)rect {
 // Drawing code
     if(!visibleKeys){
         return;
     }
 

    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    [super drawRect:rect];
     //SOPAN:
     NSLog(@"draw layers");
     //    NSLog(@"%@",dataPoints);
     //Drawing starts
     float height = rect.size.height;
     eachWidth = rect.size.width/([ dataPoints count] +1);
    
//     NSLog(@"visible keys %d", count);

     NSNumber* max = [[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"];
     
//     NSLog(@"max = %d, each width %f ", [max intValue], eachWidth);
     int i = 0;
     float x=0.0;
     for(id ky in visibleKeys){
         x = [ky floatValue]*eachWidth*scale;
//         NSLog(@"keys: %f, position %f ", [ky floatValue], x);
         float y = ([max floatValue]-[[dataPoints objectForKey:ky] floatValue])*(height/[max floatValue]);
         [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
         i++;
    }
     [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,height)] atIndexedSubscript:i];

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
     
     //path creation done, now add this path as the path of the shape layer
     self.shapeLayer.path = chart.CGPath;
     
     
 }


-(void) drawLayer{
    NSLog(@"%@",dataPoints);

}

//first time creation of the data  for the chart
-(void) setData:(NSMutableDictionary*) data {
    
    zooming = NO;
    scale =1.0;
//    UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
    UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
    
    self.shapeLayer.fillColor = lightColor.CGColor;
//    self.shapeLayer.strokeColor = darkColor.CGColor;
    
    points = [[NSMutableArray alloc] init];
    
    dataPoints = [[NSMutableDictionary alloc] init];

    title = @"Timeseries data"; // can be used as the title
    
    NSArray*  sortedKeys = [[data allKeys] sortedArrayUsingSelector: @selector(compare:)];
    //chonologically sorting, will be used for visualizing
    for(id ky in sortedKeys){
        int value=[(NSMutableArray*)[data objectForKey:ky] count];
        [dataPoints setObject:[NSNumber numberWithInt:value] forKey: ky];

    }
    visibleKeys =[[NSMutableArray alloc] init];
    visibleKeys = (NSMutableArray*)sortedKeys ;
   
    self.shapeLayer.masksToBounds = YES;

    [self setNeedsDisplay];
}


-(void) zoomTo:(float) scalez {

    zooming = YES;
    scale = scalez;
    NSRange theRange;
    theRange.location = 0;
   
    NSArray*  sortedKeys = [[dataPoints allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    float visiblePoints = self.layer.frame.size.width/(eachWidth*scale)+1;
//    NSLog(@"visible points %f", visiblePoints);
    
    if(visiblePoints <= [dataPoints count]){
        theRange.length = (int)(roundf(0.5+visiblePoints)); // considering scale = 2
//        NSLog(@"%d, %d", theRange.length, [visibleKeys count]);
        visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:theRange ] ;
    } else {
        NSLog(@"doing nothing %f, scale %f ", visiblePoints, scalez );
        scalez = 1.0;
        return;
    }
    
    [self setNeedsDisplay];
    
    

}

@end
