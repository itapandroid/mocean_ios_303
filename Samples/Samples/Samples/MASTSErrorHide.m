//
//  MASTSErrorHide.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSErrorHide.h"

@interface MASTSErrorHide ()

@end

@implementation MASTSErrorHide

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    super.adView.delegate = self;
}

#pragma mark - MASTAdViewDelegate

- (void)MASTAdViewDidRecieveAd:(MASTAdView*)adView
{
    // Show the ad view again if an update has an ad.
    adView.hidden = NO;
}

- (void)MASTAdView:(MASTAdView*)adView didFailToReceiveAdWithError:(NSError*)error
{
    // Hide the ad view if it fails for whatever reason.
    adView.hidden = YES;
}

@end
