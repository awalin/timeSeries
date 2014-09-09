//
//  UsherIPADAppDelegate.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 8/26/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherIPADAppDelegate.h"
#import "UsherIPADFileReader.h"
#import "UsherDataStructure.h"

@implementation UsherIPADAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
