//
//  MASTSDelegateNoContent.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateNoContent.h"

@interface MASTSDelegateNoContent ()

@end

@implementation MASTSDelegateNoContent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 158514;
    
    self.adView.zone = zone;
    self.adView.logLevel = MASTADViewLogEventTypeNone;
}

@end
