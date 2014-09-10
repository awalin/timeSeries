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
#import <QuartzCore/QuartzCore.h>

@implementation UsherIPADParentViewController

-(void) viewDidLoad
{
	[super viewDidLoad];
    
    
    NSLog(@"view did load");
    
    //using th backing layer of the tie series plot container
    self.timeseriesView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.timeseriesView.layer.cornerRadius = 10.0;
    self.timeseriesView.layer.frame = CGRectInset(self.view.layer.frame, 0, 0 );

    [self readFile];
    

    

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
    int aggregation = 15;
    int buckets = ([max doubleValue]-[min doubleValue])/(aggregation*1.0) +1;
    NSLog(@"%@, %@, %d", max, min, buckets);
    //the finest level of aggregation is done here before creating the time series
    for(UsherDataStructure* aTrans in allData.transactions){
        id ky= [NSNumber numberWithInt:(int)((aTrans.transTimeStamp - [min doubleValue])/aggregation)];
        int obvalue = ([timeSeries objectForKey:ky]==nil)?1:([[timeSeries objectForKey:ky] integerValue]+1);
        [timeSeries setObject:[NSNumber numberWithInt:obvalue] forKey: ky];
    }
    [allData setTimeSeries:timeSeries];
    
    NSArray *sortedKeys = [[allData.timeSeries allKeys] sortedArrayUsingSelector: @selector(compare:)];
    //    NSMutableArray *sortedValues = [NSMutableArray array];
    //    for (NSString *key in sortedKeys)
    //        [sortedValues addObject: [timeSeries objectForKey: key]];
    
    int c = 0 ;
    //sorting will be used for visualizing
    for(id ky in sortedKeys){
        NSLog(@"%@, %@", ky, [allData.timeSeries objectForKey:ky]);
        c+=[[timeSeries objectForKey:ky] intValue];
    }
    //    NSLog(@"%d", c);

}
@end
