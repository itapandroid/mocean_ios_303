//
//  MASTSSimpleInterstitialDirect.m
//  Samples
//
//  Created on 9/25/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimpleInterstitialDirect.h"

@interface MASTSSimpleInterstitialDirect ()
@property (nonatomic, retain) MASTAdView* interstitialAdView;
@end

@implementation MASTSSimpleInterstitialDirect

@synthesize interstitialAdView;

- (void)dealloc
{
    [self.interstitialAdView setDelegate:nil];
    [self.interstitialAdView reset];
    self.interstitialAdView = nil;
    
    [super dealloc];
}

- (void)refresh:(id)sender
{
    MASTSAdConfigPrompt* prompt = [[[MASTSAdConfigPrompt alloc] initWithDelegate:self
                                                                            site:self.interstitialAdView.site
                                                                            zone:self.interstitialAdView.zone] autorelease];
    [prompt show];
}

- (void)loadView
{
    [super loadView];
    
    // Remove the banner ad from the view form the Simple base class.
    [self.adView removeFromSuperview];
    [self.adView reset];
    
    // This method for interstitial doesn't require developers to place
    // and manage the interstitial view itself.  Instead it can display
    // the interstitial directly on the mainScreen with it's show and
    // close interstitial methods.  In this implementation the interstitial
    // is created on first view load and re-used when the user presses
    // the show button.  After an update and an ad is received the ad is
    // presented with showInterstitial.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.interstitialAdView == nil)
    {
        self.interstitialAdView = [[[MASTAdView alloc] initInterstitial] autorelease];
        
        self.interstitialAdView.site = 19829;
        self.interstitialAdView.zone = 88269;
        
        self.interstitialAdView.delegate = self;
        [self.interstitialAdView showCloseButton:YES afterDelay:3];
        
        [self.interstitialAdView update];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)configPrompt:(MASTSAdConfigPrompt *)prompt refreshWithSite:(NSInteger)site zone:(NSInteger)zone
{
    self.interstitialAdView.site = site;
    self.interstitialAdView.zone = zone;
    
    // Since the UIAlertView seems to nil out the keyWindow used by the SDK, must "wait" for the
    // alert view to finish and hide itself before attempting to update the ad.  Else if the update
    // happens too quickly the showInterstitial may occur before the dialog is dismissed and without
    // providing the MASTAdViewPresentingViewController to return one it won't be able to show.
    //
    // Applications should generally not have to deal with this since most interstitials will be
    // sourced by view transitions.  This is here simply becuase Samples uses a UIAlertView to
    // manually refresh ads for sample purposes.
    [self.interstitialAdView performSelector:@selector(update) withObject:nil afterDelay:1];
}

#pragma mark -

- (void)MASTAdView:(MASTAdView *)adView didFailToReceiveAdWithError:(NSError *)error
{
    
}

- (void)MASTAdViewDidRecieveAd:(MASTAdView *)adView
{
    [adView showInterstitial];
}

- (void)MASTAdViewCloseButtonPressed:(MASTAdView *)adView
{
    [adView closeInterstitial];
}

@end
