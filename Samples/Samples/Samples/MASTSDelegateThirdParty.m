//
//  MASTSDelegateThirdParty.m
//  Samples
//
//  Created on 4/21/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateThirdParty.h"

@interface MASTSDelegateThirdParty ()

@end

@implementation MASTSDelegateThirdParty

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 90038;
    
    super.adView.site = site;
    super.adView.zone = zone;
}

@end
