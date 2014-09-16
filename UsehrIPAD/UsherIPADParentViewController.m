//
//  UsherIPADParentViewController.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherIPADParentViewController.h"

#import "UsherIPADFileReader.h"
#import "UsherDataStructure.h"
#import "UsherVizContainer.h"
#import <QuartzCore/QuartzCore.h>

@implementation UsherIPADParentViewController {

    float zoomScaleCurrent;
}

-(void) viewDidLoad
{
	[super viewDidLoad];
    
    
    NSLog(@"view did load");

    self.timeseriesView  = [[UsherVizContainer alloc] initWithFrame:CGRectMake(44, 440, 245, 230)];

   
//    [self.timeseriesView setFrame:CGRectMake(0,
//                                             0,
//                                             self.timeseriesView.frame.size.width,
//                                             self.timeseriesView.frame.size.height)];
    
    [self.view addSubview:  self.timeseriesView];
    
    //using th backing layer of the tie series plot container
    self.timeseriesView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.timeseriesView.layer.cornerRadius = 10.0;
    self.timeseriesView.layer.frame = CGRectInset(self.view.layer.frame, 0, 0 );
    zoomScaleCurrent = 1.0;
    
    [self readFile];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(screenPan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(screenZoom:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];

}

-(void) screenPan: (UIPanGestureRecognizer *)gesture {
    
    
    NSLog(@" pannig ");
    //calsulate touch begin and end, and span, how to zoom
    //go to the viz container, then go to its chart view, redraw
}


-(void) screenZoom: (UIPinchGestureRecognizer *) sender{
    
    
    NSLog(@" zoom ");
    GLfloat scale;
	
    if (sender.state==UIGestureRecognizerStateBegan) {
		
	}
	else if (sender.state==UIGestureRecognizerStateChanged) {
		scale =  sender.scale;
		if (scale>4.0) scale = 4.0;
		else if (scale<0.25) scale = 0.25;
        
        [self.timeseriesView zoomTo:scale];

        
	}else if(sender.state==UIGestureRecognizerStateEnded){
        zoomScaleCurrent = scale;
    }
    
	
    //go to the viz container, then go to its chart view, redraw
}

-(void) readFile{
    
    UsherIPADFileReader *aReader = [[UsherIPADFileReader alloc] init];
    [aReader setFilename:@"Usher-selectedUsers"];
    
    UsherTimeSeries* allData = [[UsherTimeSeries alloc] init];
    [allData setTransactions:[aReader readDataFromFileAndCreateObject]];
    
    NSMutableDictionary *timeSeries = [[NSMutableDictionary alloc] init];
    //aggreagation level= hourly
    NSNumber* max = [allData.transactions valueForKeyPath: @"@max.transTimeStamp"];
    NSNumber* min = [allData.transactions valueForKeyPath: @"@min.transTimeStamp"];
  
    int aggregation = 60*60*24;//aggregate per hour
    allData.aggregation = aggregation;
    
    int buckets = ([max doubleValue]-[min doubleValue])/aggregation;
    NSLog(@"%@, %@, bins %d", max, min, buckets);
    
    //putting the transactions into bin and sending the bins to the viz container
    for(int i = 0 ; i <= buckets; i++){
        float t = [min floatValue]+i*aggregation;
        id ky = [NSNumber numberWithInt:(int)((t-[min floatValue])/aggregation)];
        NSMutableArray* values = [[NSMutableArray alloc] init];
        [timeSeries setObject:values forKey: ky];
//        NSLog(@"init key %@, %@", ky, [timeSeries objectForKey:ky]);
    }
    
    for(UsherDataStructure* aTrans in allData.transactions){
        id ky = [NSNumber numberWithInt:((aTrans.transTimeStamp- [min floatValue])/aggregation)];
        
//        int obvalue = [[timeSeries objectForKey:ky] integerValue]+1;
        NSMutableArray* mar = [timeSeries objectForKey:ky] ;
        [mar addObject:aTrans.transId]; //adding another id to the array
        [timeSeries setObject:mar forKey: ky];
      

    }
    
    [allData setTimeSeries:timeSeries];
    [self.timeseriesView setData:allData];
 
     
}

@end
