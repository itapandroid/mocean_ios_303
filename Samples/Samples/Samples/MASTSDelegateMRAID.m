//
//  MASTSDelegateMRAID.m
//  Samples
//
//  Created on 4/21/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateMRAID.h"

@interface MASTSDelegateMRAID ()

@end

@implementation MASTSDelegateMRAID

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 156037;
    
    self.adView.site = site;
    self.adView.zone = zone;
}

@end
