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
     float width = rect.size.width;
     float height = rect.size.height;
    
     int count = [[dataPoints allKeys] count];
//     NSLog(@"visible keys %d", count);
     
     NSNumber* max = [[dataPoints objectsForKeys:visibleKeys notFoundMarker:@"0"] valueForKeyPath: @"@max.self"];

     float eachWidth = width/(count+1);
     
//     NSLog(@"max = %d, each width %f ", [max intValue], eachWidth);
     int i = 0;
     for(id ky in visibleKeys){
         float x = [ky floatValue]*eachWidth*scale;
//         NSLog(@"keys: %f, position %f ", [ky floatValue], x);
         float y = ([max floatValue]-[[dataPoints objectForKey:ky] floatValue])*(height/[max floatValue]);
         [points setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] atIndexedSubscript:i];
         i++;
    }
     [points setObject:[NSValue valueWithCGPoint:CGPointMake(width,height)] atIndexedSubscript:count];

     NSValue *val = [points objectAtIndex:0];
     CGPoint point = [val CGPointValue];
     
     
     chart = [UIBezierPath bezierPath];
     [chart moveToPoint:CGPointMake(0.0, height)];
     //creating the path
     for(int i = 1; i<= count; i++){
         val = [points objectAtIndex:i];
         point = [val CGPointValue];
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
    UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
    UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
    
    self.shapeLayer.fillColor = lightColor.CGColor;
    self.shapeLayer.strokeColor = darkColor.CGColor;
    
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
   
//    NSArray*  sortedKeys = [visibleKeys sortedArrayUsingSelector: @selector(compare:)];
//    theRange.length = (int)(roundf(0.5+[visibleKeys count]/scale)); // considering scale = 2
//    NSLog(@"%d, %d", theRange.length, [visibleKeys count]);
//    visibleKeys = (NSMutableArray*)[sortedKeys subarrayWithRange:theRange ] ;
    
    [self setNeedsDisplay];
    
    

}

@end
