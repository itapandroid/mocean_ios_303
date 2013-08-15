//
//  MASTSErrorImage.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSErrorImage.h"

@interface MASTSErrorImage ()

@end

@implementation MASTSErrorImage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    super.adView.delegate = self;
}

#pragma mark - MASTAdViewDelegate

- (void)MASTAdViewDidRecieveAd:(MASTAdView*)adView
{
    // Nothing to do if the ad was previously failed with an error below since the
    // ad view will remove it's own internal image view if a text or rich media is
    // or replace the image when a new add is fetched ok.
}

- (void)MASTAdView:(MASTAdView*)adView didFailToReceiveAdWithError:(NSError*)error
{
    // Making use of the image view here...
    
    UIImage* errorImage = [UIImage imageNamed:@"errorImage"];
    
    // The MASTAdView documentation says not to place the container views anywhere that may
    // affect their placement but placing it (while not changing ANY other superview related
    // changes) is fine.
    adView.imageView.image = errorImage;
    [adView addSubview:adView.imageView];
}

@end
