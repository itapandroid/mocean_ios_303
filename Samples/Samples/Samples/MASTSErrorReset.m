//
//  MASTSErrorReset.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSErrorReset.h"

@interface MASTSErrorReset ()

@end

@implementation MASTSErrorReset

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    super.adView.delegate = self;
}

#pragma mark - MASTAdViewDelegate

- (void)MASTAdViewDidRecieveAd:(MASTAdView*)adView
{
    // Nothing to do here since any future ad load will display.
}

- (void)MASTAdView:(MASTAdView*)adView didFailToReceiveAdWithError:(NSError*)error
{
    [adView removeContent];
}

@end
