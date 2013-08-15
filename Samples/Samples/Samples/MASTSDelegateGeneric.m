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
    
    NSInteger site = 19829;
    NSInteger zone = 88269;
    
    self.adView.site = site;
    self.adView.zone = zone;
}

@end
