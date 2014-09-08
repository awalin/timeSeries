//
//  UsherIPADFileReader.h
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/8/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsherIPADFileReader : NSObject

@property NSURL *filePath;
@property NSString* filename;

-(id) readDataFromFileAndCreateObject;

@end
