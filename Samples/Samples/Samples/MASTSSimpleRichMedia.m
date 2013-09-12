//
//  MASTSSimpleRichMedia.m
//  MASTSamples
//
//  Created on 4/17/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimpleRichMedia.h"

@interface MASTSSimpleRichMedia ()

@end

@implementation MASTSSimpleRichMedia

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 98463;
    
    self.adView.zone = zone;
    
    self.adView.delegate = self;
}

#pragma mark MASTAdViewDelegate

- (BOOL)MASTAdViewSupportsCalendar:(MASTAdView *)adView
{
    return YES;
}

- (BOOL)MASTAdViewSupportsPhone:(MASTAdView *)adView
{
    return YES;
}

- (BOOL)MASTAdViewSupportsSMS:(MASTAdView *)adView
{
    return YES;
}

- (BOOL)MASTAdViewSupportsStorePicture:(MASTAdView *)adView
{
    return YES;
}

- (BOOL)MASTAdView:(MASTAdView *)adView shouldSavePhotoToCameraRoll:(UIImage *)image
{
    return YES;
}

- (BOOL)MASTAdView:(MASTAdView *)adView shouldSaveCalendarEvent:(EKEvent *)event inEventStore:(EKEventStore *)eventStore
{
    return YES;
}

@end
