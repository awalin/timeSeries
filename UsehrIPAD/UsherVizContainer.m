//
//  UsherVizContainer.m
//  UsehrIPAD
//
//  Created by Sopan, Awalin on 9/10/14.
//  Copyright (c) 2014 __mstr__. All rights reserved.
//

#import "UsherVizContainer.h"

@implementation UsherVizContainer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) init{

   id mainview = [[[NSBundle mainBundle] loadNibNamed:@"TimeseriesView"
                                   owner:self
                                 options:nil]
     objectAtIndex:0];
    [self setFrame:CGRectMake(0,
                              0,
                              self.frame.size.width,
                               self.frame.size.height)];
    return mainview;

}

@end
