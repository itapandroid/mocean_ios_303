//
//  MASTSDelegate.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegate.h"

@interface MASTSDelegate ()

@end

@implementation MASTSDelegate

@synthesize textView;

- (void)dealloc
{
    self.textView = nil;
    
    // Note: relying on the base class to reset the adView delegate.
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    // Adjust for the status bar, the navigation bar space will trigger an update layout.
    CGRect adjustedFrame = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        adjustedFrame = CGRectMake(adjustedFrame.origin.x, adjustedFrame.origin.y,
                                   adjustedFrame.size.height, adjustedFrame.size.width);
    
    adjustedFrame.size.height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    // Create a text view that captures delegate usage.
    [self.textView removeFromSuperview];

    CGRect frame = super.view.bounds;
    frame.origin.y = CGRectGetMaxY(self.adView.frame);
    frame.size.height -= frame.origin.y;
    self.textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.editable = NO;
    
    [self.view addSubview:self.textView];
    [self.view sendSubviewToBack:self.textView];
    
    self.adView.delegate = self;
}

#pragma mark - 

- (void)writeEntry:(NSString*)entry
{
    NSString* text = [self.textView.text stringByAppendingFormat:@"\n%@\n--", entry];
    self.textView.text = text;

    [self.textView scrollRangeToVisible:NSMakeRange(text.length, 0)];
}

#pragma mark -

- (void)MASTAdViewDidRecieveAd:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewDidRecieveAd:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdView:(MASTAdView*)adView didFailToReceiveAdWithError:(NSError*)error
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:didFailToReceiveAdWithError:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nerror: %@", [error description]];
    
    [self writeEntry:entry];
}

- (BOOL)MASTAdView:(MASTAdView*)adView shouldOpenURL:(NSURL*)url
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:shouldOpenURL:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nurl: %@", [url description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (void)MASTAdViewCloseButtonPressed:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewCloseButtonPressed:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (UIButton*)MASTAdViewCustomCloseButton:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewCustomCloseButton:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
    
    return nil;
}

- (void)MASTAdViewWillExpand:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewWillExpand:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewDidExpand:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewDidExpand:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdView:(MASTAdView *)adView willResizeToFrame:(CGRect)frame
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:willResizeToFrame:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    CFDictionaryRef ref = CGRectCreateDictionaryRepresentation(frame);
    [entry appendFormat:@"\nframe: %@", [((NSDictionary*)ref) description]];
    CFRelease(ref);
    
    [self writeEntry:entry];
}

- (void)MASTAdView:(MASTAdView *)adView didResizeToFrame:(CGRect)frame
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:didResizeToFrame:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    CFDictionaryRef ref = CGRectCreateDictionaryRepresentation(frame);
    [entry appendFormat:@"\nframe: %@", [((NSDictionary*)ref) description]];
    CFRelease(ref);
    
    [self writeEntry:entry];
}

- (void)MASTAdViewWillCollapse:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewWillCollapse"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewDidCollapse:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewDidCollapse:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewInternalBrowserWillOpen:(MASTAdView *)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewInternalBrowserWillOpen:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewInternalBrowserDidOpen:(MASTAdView *)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewInternalBrowserDidOpen:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewInternalBrowserWillClose:(MASTAdView *)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewInternalBrowserWillClose:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewInternalBrowserDidClose:(MASTAdView *)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewInternalBrowserDidClose:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (void)MASTAdViewWillLeaveApplication:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewWillLeaveApplication:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
}

- (BOOL)MASTAdView:(MASTAdView*)adView shouldLogEvent:(NSString*)event ofType:(MASTAdViewLogEventType)type
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:shouldLogEvent:ofType:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nevent: %@", [event description]];
    [entry appendFormat:@"\ntype: %d", type];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdViewSupportsSMS:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewSupportsSMS:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdViewSupportsPhone:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewSupportsPhone:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdViewSupportsCalendar:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewSupportsCalendar:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdViewSupportsStorePicture:(MASTAdView*)adView
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdViewSupportsStorePicture:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (void)MASTAdView:(MASTAdView*)adView didReceiveThirdPartyRequest:(NSDictionary*)properties withParams:(NSDictionary*)params
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:didReceiveThirdPartyRequest:withParams"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nproperties: %@", [properties description]];
    [entry appendFormat:@"\nparams: %@", [params description]];
    
    [self writeEntry:entry];
}

- (BOOL)MASTAdView:(MASTAdView*)adView shouldPlayVideo:(NSString*)videoURL
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:shouldPlayVideo:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nvideoURL: %@", [videoURL description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdView:(MASTAdView*)adView shouldSaveCalendarEvent:(EKEvent*)event inEventStore:(EKEventStore*)eventStore
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:shouldSaveCalendarEvent:inEventStore:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nevent: %@", [event description]];
    [entry appendFormat:@"\neventStore: %@", [eventStore description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (BOOL)MASTAdView:(MASTAdView*)adView shouldSavePhotoToCameraRoll:(UIImage*)image
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:shouldSavePhotoToCameraRoll:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nimage: %@", [image description]];
    
    [self writeEntry:entry];
    
    return YES;
}

- (void)MASTAdView:(MASTAdView *)adView didProcessRichmediaRequest:(NSURLRequest*)event
{
    NSMutableString* entry = [NSMutableString stringWithString:@"MASTAdView:didProcessRichmediaRequest:"];
    [entry appendFormat:@"\nadView: %@", [adView description]];
    [entry appendFormat:@"\nevent: %@", [event description]];
    
    [self writeEntry:entry];
}

@end
