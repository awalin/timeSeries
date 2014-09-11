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

 - (void)drawRect:(CGRect)dirtyRect {
 // Drawing code
//     
    [[UIColor blueColor] setFill];
    UIRectFill(dirtyRect);
    [super drawRect:dirtyRect];
     //SOPAN:
 //draw the layer with time series data
//    [self drawLayer];
     UIBezierPath *aPath = [UIBezierPath bezierPath];
     
     
     // Set the starting point of the shape.
     [aPath moveToPoint:CGPointMake(50.0, 10.0)];
     
     // Draw the lines.
     [aPath addLineToPoint:CGPointMake(200.0, 30.0)];
     [aPath addLineToPoint:CGPointMake(160, 140)];
     [aPath addLineToPoint:CGPointMake(40.0, 140)];
     [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
     [aPath closePath];
//     // Create an oval shape to draw.
//     UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:
//                            CGRectMake(0, 0, 200, 100)];
     
     // Set the render colors.
     [[UIColor blackColor] setStroke];
     [[UIColor redColor] setFill];
     
//     CGContextRef aRef = UIGraphicsGetCurrentContext();
     
     // If you have content to draw after the shape,
     // save the current state before changing the transform.
     //CGContextSaveGState(aRef);
     
     // Adjust the view's origin temporarily. The oval is
     // now drawn relative to the new origin point.
//     CGContextTranslateCTM(aRef, 50, 50);
     
     // Adjust the drawing options as needed.
     aPath.lineWidth = 5;
     
     // Fill the path before stroking it so that the fill
     // color does not obscure the stroked line.
     [aPath fill];
     [aPath stroke];
 
 }


-(void) drawLayer{
    
    if(![self dataPoints]){
        return;
    }
    
    NSLog(@"draw layers");
//    NSLog(@"%@",dataPoints);
    //Drawing starts
    NSArray *sortedKeys = [[dataPoints allKeys] sortedArrayUsingSelector: @selector(compare:)];
    //    NSMutableArray *sortedValues = [NSMutableArray array];
    //    for (NSString *key in sortedKeys)
    //        [sortedValues addObject: [timeSeries objectForKey: key]];
    
//    int c = 0 ;
    //chonologically sorting, will be used for visualizing
    for(id ky in sortedKeys){
//        NSLog(@"%@, %@", ky, [dataPoints objectForKey:ky]);
     //   c+=[[dataPoints objectForKey:ky] intValue];
    }
    
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
