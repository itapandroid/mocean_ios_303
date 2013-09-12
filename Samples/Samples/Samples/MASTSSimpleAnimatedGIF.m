//
//  MASTSSimpleAnimatedGIF.m
//  Samples
//
//  Created on 11/5/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimpleAnimatedGIF.h"

@interface MASTSSimpleAnimatedGIF ()

@end

@implementation MASTSSimpleAnimatedGIF

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 146951;
    
    super.adView.site = site;
    super.adView.zone = zone;
}

@end
