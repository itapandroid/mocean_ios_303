//
//  MASTSAdvancedAnimation.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSAdvancedAnimation.h"

@interface MASTSAdvancedAnimation ()

@end

@implementation MASTSAdvancedAnimation

- (void)loadView
{
    [super loadView];
    
    super.adView.delegate = self;
    
    // Take the simple configuration frame (top banner) and move it off screen
    // until an ad is displayed then move/animate it on screen.
    CGRect frame = self.adView.frame;
    frame.origin.y -= frame.size.height;
    self.adView.frame = frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 88269;
    
    super.adView.zone = zone;
}

#pragma mark - animations

- (void)animateHideAd
{
    CGRect frame = self.adView.frame;
    frame.origin.y = 0 - frame.size.height;
    self.adView.frame = frame;
}

- (void)animateShowAd
{
    [UIView animateWithDuration:.5
                     animations:^
     {
         CGRect frame = self.adView.frame;
         frame.origin.y = 0;
         self.adView.frame = frame;
     }];
}

#pragma mark - MASTAdViewDelegate

- (void)MASTAdViewDidRecieveAd:(MASTAdView *)adView
{
    NSLog(@"MASTAdViewDidRecieveAd:");

    [self performSelectorOnMainThread:@selector(animateShowAd) withObject:nil waitUntilDone:NO];
}

- (void)MASTAdView:(MASTAdView *)adView didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"MASTAdView:didFailToReceiveAdWithError:");
    
    [self performSelectorOnMainThread:@selector(animateHideAd) withObject:nil waitUntilDone:NO];
}

#pragma mark -

- (void)configPrompt:(MASTSAdConfigPrompt*)prompt refreshWithZone:(NSInteger)zone
{
    [self animateHideAd];
    [super configPrompt:prompt refreshWithZone:zone];
}

@end
