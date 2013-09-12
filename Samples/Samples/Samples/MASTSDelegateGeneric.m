//
//  MASTSDelegateGeneric.m
//  Samples
//
//  Created on 4/21/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateGeneric.h"

@interface MASTSDelegateGeneric ()

@end

@implementation MASTSDelegateGeneric

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 88269;
    
    self.adView.zone = zone;
    self.adView.logLevel = MASTADViewLogEventTypeNone;
}

@end
