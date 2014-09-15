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

@implementation UsherIPADParentViewController

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
    
    
    [self readFile];

}

-(void) readFile{
    
    UsherIPADFileReader *aReader = [[UsherIPADFileReader alloc] init];
    [aReader setFilename:@"usher-HQ"];
    UsherTimeSeries* allData = [[UsherTimeSeries alloc] init];
    [allData setTransactions:[aReader readDataFromFileAndCreateObject]];
    
    NSMutableDictionary *timeSeries = [[NSMutableDictionary alloc] init];
    //aggreagation level= hourly
    NSNumber* max = [allData.transactions valueForKeyPath: @"@max.transTimeStamp"];
    NSNumber* min = [allData.transactions valueForKeyPath: @"@min.transTimeStamp"];
    int aggregation = 60*60*24;//aggregate per hour
    int buckets = ([max doubleValue]-[min doubleValue])/aggregation;
    NSLog(@"%@, %@, bins %d", max, min, buckets);
    //the finest level of aggregation is done here before creating the time series
    for(int i = 0 ; i <= buckets; i++){
        float t = [min floatValue]+i*aggregation;
        id ky = [NSNumber numberWithInt:(int)(t/aggregation)];
        [timeSeries setObject:[NSNumber numberWithInt:0] forKey: ky];
    }
    
    for(UsherDataStructure* aTrans in allData.transactions){
        id ky = [NSNumber numberWithInt:((aTrans.transTimeStamp- [min floatValue])/aggregation)];
        int obvalue = [[timeSeries objectForKey:ky] integerValue]+1;
        [timeSeries setObject:[NSNumber numberWithInt:obvalue] forKey: ky];
    }
    [allData setTimeSeries:timeSeries];
    [self.timeseriesView setData:allData.timeSeries];
    
}

@end
