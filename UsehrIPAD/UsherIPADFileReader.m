//
//  UsherIPADFileReader.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/8/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherIPADFileReader.h"
#import "UsherDataStructure.h"

@implementation UsherIPADFileReader



-(id) readDataFromFileAndCreateObject{
   
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:self.filename
                                                     ofType:@"csv"];

    NSString *stringFromFile = [[NSString alloc]
                  initWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:&error];
    
    if (stringFromFile == nil) {
        // an error occurred
        NSLog(@"Error reading file at %@\n%@",
              _filePath, [error localizedFailureReason]);
        // implementation continues ...
    }
    
//    NSLog(@"%@", path);
    NSArray* lines = [stringFromFile componentsSeparatedByString:@"\r"] ;
    int totalRows = [lines count]-1;
    NSMutableDictionary *transactions = [[NSMutableDictionary alloc] init];
    NSLog(@"Total %d", totalRows);
    
    //start  showing progress bar here, sends message to the controller//
    //parse the line and create the objects
    for(int i=1; i<= totalRows; i++){ // skip the first line of the file, so i = 1
        //        NSLog(@"%d, %@",i,[items objectAtIndex:i]);
      NSString *line = [lines objectAtIndex:i];
      NSArray* fields = [line componentsSeparatedByString:@","];
        
//       NSLog(@"%@",fields);
        UsherDataStructure *aTransaction = [[UsherDataStructure alloc] init];
        //here populate the array objects
        [aTransaction createDataObject: fields];
        [transactions setObject:aTransaction forKey:aTransaction.transId];//adding the new object to the array
    }
    
    NSLog(@"Total rows: %d", totalRows);

    
    return transactions;
}

@end
