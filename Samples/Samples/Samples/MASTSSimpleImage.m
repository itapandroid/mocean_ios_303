//
//  MASTSSimpleImage.m
//  MASTSamples
//
//  Created on 4/17/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimpleImage.h"

@interface MASTSSimpleImage ()

@end


@implementation MASTSSimpleImage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 88269;
    
    super.adView.site = site;
    super.adView.zone = zone;
}

@end
