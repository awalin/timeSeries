//
//  UsherTimeseriesViz.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherTimeseriesViz.h"



@implementation UsherTimeseriesViz


@synthesize title ;
@synthesize dataPoints;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.*/
+ (Class) layerClass {
    return [CAShapeLayer class];
}
-(id) init{
    
    self = [super init];
    return self;
}


- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}


 - (void)drawRect:(CGRect)rect {
 // Drawing code
     if(![self dataPoints]){
     return;
     }


    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    [super drawRect:rect];
     //SOPAN:
     NSLog(@"draw layers");
     //    NSLog(@"%@",dataPoints);
     //Drawing starts
     NSMutableArray*  sortedKeys = [[dataPoints allKeys] sortedArrayUsingSelector: @selector(compare:)];
     int count = [sortedKeys count];
     //    NSMutableArray *sortedValues = [NSMutableArray array];
     //    for (NSString *key in sortedKeys)
     //        [sortedValues addObject: [timeSeries objectForKey: key]];
     
     
     float width = rect.size.width;
     float height = rect.size.height;
    NSMutableArray* points = [[NSMutableArray alloc] init];
     //chonologically sorting, will be used for visualizing
     for(id ky in sortedKeys){
         NSLog(@"keys %@, %@", ky, [dataPoints objectForKey:ky]);
         float x = [ky doubleValue]*width/(count+1);
         float y = (681.0-[[dataPoints objectForKey:ky] doubleValue])*(height/630.0);//+height;
         [points addObject:[NSValue valueWithCGPoint:CGPointMake(x,y)]];
         //   c+=[[dataPoints objectForKey:ky] intValue];
     }
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(width,height)]];

     
//     CGContextRef context = UIGraphicsGetCurrentContext();
//     CGContextSaveGState(context);
//     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

  // Adjust the drawing options as needed.
     UIBezierPath *chart = [UIBezierPath bezierPath];
     UIColor * darkColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:67.0/255.0 alpha:1];
     UIColor * lightColor = [UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:90.0/255.0 alpha:0.6];
     // Set the render colors.
//     [darkColor setStroke];
//     [lightColor setFill];


     NSValue *val = [points objectAtIndex:0];
     CGPoint point = [val CGPointValue];
     
     [chart moveToPoint:CGPointMake(0.0, height)];
     //creating the path
     for(int i = 1; i<=count; i++){
         val = [points objectAtIndex:i];
         point = [val CGPointValue];
         
         NSValue* val2 = [points objectAtIndex:i-1] ;
         CGPoint point2 = [val2 CGPointValue];
         
         float x = (point2.x+point.x)/2.0;
         float y = (point2.y+point.y)/2.0;
         CGPoint ctrl = CGPointMake(x,y);
          [chart  addQuadCurveToPoint: point controlPoint:ctrl];
//         CGContextAddQuadCurveToPoint(context, 150, 10, 300, 200);
//         [chart  addLineToPoint: point];

     }
     
//     [chart moveToPoint:CGPointMake(width,height)];
     [chart closePath];
     
     //path creation done, now add this path as the path of the shape layer
     self.shapeLayer.path = chart.CGPath;
     self.shapeLayer.fillColor = lightColor.CGColor;
     self.shapeLayer.strokeColor = darkColor.CGColor;
     
//     [chart fill];
//     [chart stroke];
//     CGContextRestoreGState(context);
//     CGGradientRelease(mountainGrad);
 
 }


-(void) drawLayer{
    NSLog(@"%@",dataPoints);

}
//
-(void) setData:(NSMutableDictionary*) data{
    
//    self = [super init];

    dataPoints = [[NSMutableDictionary alloc] initWithDictionary:data];
    title = @"Timeseries data"; // can be used as the title
    
    [self setNeedsDisplay];
}


@end
