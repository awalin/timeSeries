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
#import "UsherTimeseriesViz.h"
#import <QuartzCore/QuartzCore.h>

#import "UsherIPADTooltipContent.h"

@implementation UsherIPADParentViewController {

    float zoomScaleCurrent;
    float scale;
    float translate;
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
    scale = 1.0;
    [self readFile];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(screenPan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(screenZoom:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTooltip:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEasing:) name:@"Easing" object:nil];


}


-(void) showTooltip: (UITapGestureRecognizer*) sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self.timeseriesView showTooltip:sender];
    
        
   }


}

-(void)handleEasing:(NSNotification *)note
{   if (self.popOverController) {
    [self.popOverController dismissPopoverAnimated:YES];
    
    NSLog(@"handled easing");
    }
}

//may not be needed anymore
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
        NSLog(@"popover closed");
       [[NSNotificationCenter defaultCenter] postNotificationName:@"Easing" object:self userInfo:nil];
}


-(void) screenPan: (UIPanGestureRecognizer *)sender {
    
   if (sender.state==UIGestureRecognizerStateBegan) {
   
       translate = [sender translationInView:(UIView*)self.timeseriesView.mainViz].x;
       NSLog(@" pannig translation in view %f", translate);
       if(fabs(translate)>0.0)
           [self.timeseriesView.mainViz panView:translate];
	}
	else if (sender.state==UIGestureRecognizerStateChanged) {
   
       CGPoint translatenow =[sender translationInView:(UIView*)self.timeseriesView.mainViz];
       float delta = translatenow.x-translate;
        NSLog(@" pannig delta %f", delta);
        if(fabs(delta)>0.0)
                [self.timeseriesView.mainViz panView:delta];
        
	}else if(sender.state==UIGestureRecognizerStateEnded){
        
  }

}



-(void) screenZoom: (UIPinchGestureRecognizer *) sender{
    
      if (sender.state==UIGestureRecognizerStateBegan) {
        zoomScaleCurrent = 1.0;
        NSLog(@"current zoom scale %f", zoomScaleCurrent) ;
       [self.timeseriesView.mainViz adjustAnchor: sender];
          
    } else if (sender.state==UIGestureRecognizerStateChanged) {
        scale = 1.0 -(zoomScaleCurrent - sender.scale);
        zoomScaleCurrent = sender.scale;
        [self.timeseriesView zoomTo:scale];
        
        
   }else if(sender.state==UIGestureRecognizerStateEnded){
//        zoomScaleCurrent = scale;
        // dragging finished, now adjust the y-axis values
        [self.timeseriesView adjustYvalues];
        
        // now update aggregation if needed
        
        
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
    NSNumber* max = [[allData.transactions allValues] valueForKeyPath: @"@max.transTimeStamp"];
    NSNumber* min = [[allData.transactions allValues] valueForKeyPath: @"@min.transTimeStamp"];
  
    float aggregation = 60*60*24;//aggregate per hour

    
    float width = 600.0;//self.timeseriesView.mainViz.layer.frame.size.width;
    float diff = [max floatValue]-[min floatValue];
    float agg = (diff)/width;
    
    NSLog(@"%f, %f", diff, agg);
    
    if( agg >60*60 && agg<=60*60*24){
        aggregation = 60*60*24;//day
        NSLog(@" Day ,%f", diff/agg);
    
    }
    else if( agg <=60*60 && agg > 60){
        aggregation = 60*60;//hour
        NSLog(@" Hour ");

    }
    
    allData.aggregation = aggregation;
    
    int buckets = (diff)/allData.aggregation;
    NSLog(@"%@, %@, bins %d", max, min, buckets);
    
    //putting the transactions into bin and sending the bins to the viz container
    for(int i = 0 ; i < buckets; i++){
        float t = [min floatValue]+i*aggregation;
        id ky = [NSNumber numberWithInt:(int)((t-[min floatValue])/aggregation)];
        NSMutableArray* values = [[NSMutableArray alloc] init];
        [timeSeries setObject:values forKey: ky];
    }
    int i = 0 ;
    for(UsherDataStructure* aTrans in [allData.transactions allValues]){
        id ky = [NSNumber numberWithInt:((aTrans.transTimeStamp- [min floatValue])/aggregation)];
//         NSLog(@"init key %@, %@ %d, %@", ky, [timeSeries objectForKey:ky],i ,aTrans.transId);
//        int obvalue = [[timeSeries objectForKey:ky] integerValue]+1;
        if([timeSeries objectForKey:ky]!=NULL){
            NSMutableArray* mar = [timeSeries objectForKey:ky] ;
            [mar addObject:aTrans.transId]; //adding another id to the array
            [timeSeries setObject:mar forKey: ky];
        
        }else {
            NSMutableArray* mar = [[NSMutableArray alloc] init];
            [timeSeries setObject:mar forKey: ky];
            [mar addObject:aTrans.transId]; //adding another id to the array
            [timeSeries setObject:mar forKey: ky];
        
        }
       
        i++;

    }
    NSLog(@"Object creation done");
    
    [allData setTimeSeries:timeSeries];
    [self.timeseriesView setData:allData];
 
     
}

@end
