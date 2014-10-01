//
//  UsherIPADTooltipContent.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/26/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherIPADTooltipContent.h"

@interface UsherIPADTooltipContent ()

@end

@implementation UsherIPADTooltipContent

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"inside pop");
    self.preferredContentSize = CGSizeMake(80, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createContent:(int) tot forDate:(NSString*)_date{
    
    CATextLayer* dateLayer = [CATextLayer layer];
    dateLayer.string = _date;
    dateLayer.frame = CGRectMake(5, 2, 60, 10);
    [dateLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
    dateLayer.position = CGPointMake(5,2);
    dateLayer.foregroundColor = [UIColor whiteColor].CGColor;
    [dateLayer setFontSize:10.0];
    
    
    
    CATextLayer* totLayer = [CATextLayer layer];
    totLayer.string = [NSString stringWithFormat:@"Total %d entries",tot ] ;
    [totLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
    totLayer.position = CGPointMake(5,15);
    totLayer.foregroundColor = [UIColor whiteColor].CGColor;
    [totLayer setFontSize:10.0];
    totLayer.frame = CGRectMake(5, 15, 80, 10);
    [self.view.layer addSublayer:dateLayer];
    [self.view.layer addSublayer:totLayer];
    
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
