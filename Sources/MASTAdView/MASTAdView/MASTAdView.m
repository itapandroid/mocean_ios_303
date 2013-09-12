//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.
//

#import "MASTDefaults.h"
#import "MASTConstants.h"
#import "MASTAdView.h"
#import "MASTURLProtocol.h"
#import "UIWebView+MASTAdView.h"
#import "NSDictionary+MASTAdView.h"
#import "NSDate+MASTAdView.h"
#import "UIImageView+MASTAdView.h"
#import "MASTMRAIDBridge.h"
#import "MASTMoceanAdResponse.h"
#import "MASTMoceanAdDescriptor.h"
#import "MASTMoceanThirdPartyDescriptor.h"
#import "MASTAdTracking.h"
#import "MASTAdBrowser.h"
#import "MASTModalViewController.h"

#import "MASTCloseButtonPNG.h"

#import <objc/runtime.h>
#import <CoreTelephony/CTCarrier.h>


static NSString* AdViewUserAgent = nil;
static BOOL registerProtocolClass = YES;

@interface MASTAdView () <UIGestureRecognizerDelegate, UIWebViewDelegate, MASTMRAIDBridgeDelegate,
    MASTAdBrowserDelegate, MASTModalViewControllerDelegate, CLLocationManagerDelegate, EKEventEditViewDelegate>

// Ad fetching
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* dataBuffer;

// Update timer
@property (nonatomic, strong) NSTimer* updateTimer;

// Set to skip the next timer update
@property (nonatomic, assign) BOOL skipNextUpdateTick;

// Set to indicate an update should occur after user interaction is done.
@property (nonatomic, assign) BOOL deferredUpdate;

// Interstitial delay timer
@property (nonatomic, strong) NSTimer* interstitialTimer;

// Close button
@property (nonatomic, assign) NSTimeInterval closeButtonTimeInterval;
@property (nonatomic, strong) NSTimer* closeButtonTimer;
@property (nonatomic, strong) UIButton* closeButton;

// Gesture for non-mraid/web ads
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

// SDK provided close areas
@property (nonatomic, strong) UIControl* expandCloseControl;
@property (nonatomic, strong) UIControl* resizeCloseControl;

// Descriptor of active ad
@property (nonatomic, strong) MASTMoceanAdDescriptor* adDescriptor;

// MRAID 2.0
@property (nonatomic, strong) MASTMRAIDBridge* mraidBridge;

// Internal Browser
@property (nonatomic, strong) MASTAdBrowser* adBrowser;

// Used to render interstitial, expand and internal browser.
@property (nonatomic, strong) MASTModalViewController* modalViewController;

// If for some reason the modal needs to be dismissed before the presentation is complete, this flag is set.
@property (nonatomic, assign) BOOL modalDismissAfterPresent;

// Used to re-expand the ad if a calendar event is  created.
@property (nonatomic, assign) BOOL calendarReExpand;

// Used to track state of the status bar prior to modal view.
@property (nonatomic, assign) BOOL statusBarHidden;

// Determines if this ad is an expand URL ad.
@property (nonatomic, assign) BOOL isExpandedURL;

// Used to display MRAID expand URL.
@property (nonatomic, strong) MASTAdView* expandedAdView;

// Used to track if if tracking is needed for the ad descriptor.
@property (nonatomic, assign) BOOL invokeTracking;

// For location services
@property (nonatomic, strong) CLLocationManager* locationManager;

// Using the rootViewController, determines the view that the resizeView uses as a superview.
- (UIView*)resizeViewSuperview;

// Inspects ad descriptor and configures views and loads the ad.
- (void)loadContent:(NSData*)content;

// Invokes ad tracking as needed.
- (void)performAdTracking;

// Returns the size of the screen taking rotation into consideration.
// Including the status bar will reduce the size by the amount of the status
// bar if visible.
- (CGSize)screenSizeIncludingStatusBar:(BOOL)includeStatusBar;

// Returns the current frame as it is positioned in it's window.
// If not on a window, returns the raw frame as-is.
- (CGRect)absoluteFrameForView:(UIView*)view;

@end


@implementation MASTAdView

@synthesize labelView, imageView, expandView, resizeView;
@synthesize zone, useInternalBrowser, placementType;
@synthesize adServerURL, adRequestParameters;
@synthesize test, logLevel;
@synthesize delegate;
@synthesize connection, dataBuffer, webView;
@synthesize updateTimer, skipNextUpdateTick, deferredUpdate, interstitialTimer;
@synthesize closeButtonTimeInterval, closeButtonTimer, closeButton;
@synthesize tapGesture;
@synthesize expandCloseControl, resizeCloseControl;
@synthesize adDescriptor;
@synthesize mraidBridge;
@synthesize adBrowser;
@synthesize modalViewController, modalDismissAfterPresent, calendarReExpand, statusBarHidden;
@synthesize isExpandedURL;
@synthesize expandedAdView;
@synthesize invokeTracking;
@synthesize locationManager;
@synthesize locationDetectionEnabled;


#pragma mark -

+ (NSString*)version
{
    return MAST_DEFAULT_VERSION;
}

+ (void)unregisterProtocolClass
{
    registerProtocolClass = YES;

    [NSURLProtocol unregisterClass:[MASTURLProtocol class]];
}

#pragma mark -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.closeButtonTimer invalidate];

    [self reset];
    
    [self.mraidBridge setDelegate:nil];
    self.mraidBridge = nil;

    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    self.webView = nil;
    
    [self setLocationDetectionEnabled:NO];
}

#pragma markv - Init

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initInterstitial
{
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        placementType = MASTAdViewPlacementTypeInterstitial;
        
        [self.expandView addGestureRecognizer:self.tapGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (AdViewUserAgent == nil)
    {
        UIWebView* wv = [[UIWebView alloc] initWithFrame:CGRectZero];
        AdViewUserAgent = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizesSubviews = YES;
        
        self.logLevel = MASTAdViewLogEventTypeError;
        
        placementType = MASTAdViewPlacementTypeInline;
        
        self.adServerURL = MAST_DEFAULT_AD_SERVER_URL;
        adRequestParameters = [NSMutableDictionary new];
        
        self.closeButtonTimeInterval = -1;

        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        self.tapGesture.delegate = self;
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

#pragma mark - Update

- (void)internalUpdate
{
    self.deferredUpdate = NO;
    
    // Don't update if the internal browser is up.
    if ([self adBrowserOpen])
    {
        self.deferredUpdate = YES;
        return;
    }
    
    // Don't update if an MRAID ad is expanded or resized.
    switch ([self.mraidBridge state])
    {
        case MASTMRAIDBridgeStateLoading:
        case MASTMRAIDBridgeStateDefault:
        case MASTMRAIDBridgeStateHidden:
            break;
            
        case MASTMRAIDBridgeStateExpanded:
        case MASTMRAIDBridgeStateResized:
            self.deferredUpdate = YES;
            return;
    }
    
    if (self.zone == 0)
    {
        [self logEvent:@"Can not update without a proper zone."
                ofType:MASTAdViewLogEventTypeError
                  func:__func__
                  line:__LINE__];
        
        if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
        {
            NSError* error = [NSError errorWithDomain:@"Missing zone."
                                                 code:0
                                             userInfo:nil];
            
            [self invokeDelegateBlock:^
            {
                [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
            }];
        }
        
        return;
    }
    
    CGSize size = self.bounds.size;
    
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
    {
        size = [UIScreen mainScreen].bounds.size;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            size = CGSizeMake(size.height, size.width);
        }
    }
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat size_x = size.width * scale;
    CGFloat size_y = size.height * scale;
    
    // Args passed to the ad server.
    NSMutableDictionary* args = [NSMutableDictionary new];
    
    
    // Set default args that can be overriden.
    [args setValue:[NSString stringWithFormat:@"%d", (int)size_x] forKey:@"size_x"];
    [args setValue:[NSString stringWithFormat:@"%d", (int)size_y] forKey:@"size_y"];
    
    
    // Fetch the defaults for the cell info (can be overriden as well).
    CTTelephonyNetworkInfo* networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier* carrier = [networkInfo subscriberCellularProvider];
    NSString* mcc = [carrier mobileCountryCode];
    NSString* mnc = [carrier mobileNetworkCode];
    
    if ([mcc length] > 0)
        [args setValue:[NSString stringWithFormat:@"%@", mcc] forKey:@"mcc"];

    if ([mnc length] > 0)
        [args setValue:[NSString stringWithFormat:@"%@", mnc] forKey:@"mnc"];
    

    // Import developer args..
    [args addEntriesFromDictionary:self.adRequestParameters];
    
    
    // Set values that are not to be overriden.
    [args setValue:AdViewUserAgent forKey:@"ua"];
    [args setValue:[MASTAdView version] forKey:@"version"];
    [args setValue:@"1" forKey:@"count"];
    [args setValue:@"3" forKey:@"key"];
    [args setValue:[NSString stringWithFormat:@"%d", self.zone] forKey:@"zone"];
    
    if (self.test)
        [args setValue:@"1" forKey:@"test"];
    
    
    NSMutableString* url = [NSMutableString stringWithFormat:@"%@?", self.adServerURL];
    
    for (NSString* argKey in args.allKeys)
    {
        [url appendFormat:@"%@=%@&", argKey, [args valueForKey:argKey]];
    }
    [url deleteCharactersInRange:NSMakeRange([url length] - 1, 1)];
    
    NSString* requestUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self logEvent:[NSString stringWithFormat:@"Ad request: %@", requestUrl]
            ofType:MASTAdViewLogEventTypeDebug
              func:__func__
              line:__LINE__];

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:MAST_DEFAULT_NETWORK_TIMEOUT];
    
    self.dataBuffer = nil;
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request 
                                                      delegate:self 
                                              startImmediately:YES];
}

- (void)internalUpdateTimerTick
{
    if (self.window == nil)
        return;
    
    if (self.skipNextUpdateTick)
        self.skipNextUpdateTick = NO;
    
    [self internalUpdate];
}

- (void)update
{
    [self update:NO];
}

- (void)update:(BOOL)force
{
    // If iOS 6 determine if the calendar can be used and ask user for authorization if necessary.
    [self checkCalendarAuthorizationStatus];

    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
    }
    
    if (force)
    {
        // Close the ad browser if open.
        if ([self adBrowserOpen])
        {
            [self closeAdBrowser];
        }
        
        // Close interstitial if interstitial.
        [self closeInterstitial];
        
        // Do non-interstitial cleanup after this.
        if (self.placementType == MASTAdViewPlacementTypeInline)
        {
            // Close any expanded or resized MRAID ad.
            switch ([self.mraidBridge state])
            {
                case MASTMRAIDBridgeStateLoading:
                case MASTMRAIDBridgeStateDefault:
                case MASTMRAIDBridgeStateHidden:
                    break;
                    
                case MASTMRAIDBridgeStateExpanded:
                case MASTMRAIDBridgeStateResized:
                    [self mraidBridgeClose:self.mraidBridge];
                    break;
            }
        }
    }
    
    // Cancel any current request
    [self.connection cancel];
    self.connection = nil;
    
    [self internalUpdate];
}

- (void)updateWithTimeInterval:(NSTimeInterval)interval
{
    if (interval == 0)
    {
        [self update];
        return;
    }
    
    // If iOS 6 determine if the calendar can be used and ask user for authorization if necessary.
    [self checkCalendarAuthorizationStatus];

    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
    }

    self.updateTimer = [[NSTimer alloc] initWithFireDate:nil
                                                interval:interval
                                                  target:self
                                                selector:@selector(internalUpdateTimerTick)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
}

- (void)reset
{
    self.deferredUpdate = NO;
    
    // Close the ad browser if open.
    if ([self adBrowserOpen])
    {
        [self closeAdBrowser];
    }
    
    // Close interstitial if interstitial.
    [self closeInterstitial];
    
    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
    }
    
    // Stop the interstitial timer
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
    }
    
    // Cancel any current request
    [self.connection cancel];
    self.connection = nil;
    
    // Stop location detection
    [self setLocationDetectionEnabled:NO];
    
    // Do non-interstitial cleanup after this.
    if (self.placementType != MASTAdViewPlacementTypeInline)
        return;
    
    // Close any expanded or resized MRAID ad.
    switch ([self.mraidBridge state])
    {
        case MASTMRAIDBridgeStateLoading:
        case MASTMRAIDBridgeStateDefault:
        case MASTMRAIDBridgeStateHidden:
            break;
            
        case MASTMRAIDBridgeStateExpanded:
        case MASTMRAIDBridgeStateResized:
            [self mraidBridgeClose:self.mraidBridge];
            break;
    }
    
    [self resetImageAd];
    [self resetTextAd];
    [self resetWebAd];
}

- (void)removeContent
{
    self.deferredUpdate = NO;
    
    [self closeInterstitial];
    
    // Do non-interstitial cleanup after this.
    if (self.placementType != MASTAdViewPlacementTypeInline)
        return;
    
    // Close any expanded or resized MRAID ad.
    switch ([self.mraidBridge state])
    {
        case MASTMRAIDBridgeStateLoading:
        case MASTMRAIDBridgeStateDefault:
        case MASTMRAIDBridgeStateHidden:
            break;
            
        case MASTMRAIDBridgeStateExpanded:
        case MASTMRAIDBridgeStateResized:
            [self mraidBridgeClose:self.mraidBridge];
            break;
    }
    
    [self resetImageAd];
    [self resetTextAd];
    [self resetWebAd];
}

- (void)resumeUpdates
{
    if (self.deferredUpdate)
    {
        [self update];
    }
    
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) 
                                           withObject:nil
                                        waitUntilDone:YES];
        
        self.updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.updateTimer.timeInterval]
                                                    interval:self.updateTimer.timeInterval
                                                      target:self
                                                    selector:@selector(internalUpdate)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark - Two Creative Expand

- (void)showExpanded:(NSString*)url
{
    self.isExpandedURL = YES;
    
    // Cancel any current request
    [self.connection cancel];
    self.connection = nil;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeoutInterval:MAST_DEFAULT_NETWORK_TIMEOUT];
    
    [self performSelectorOnMainThread:@selector(renderMRAIDAd:)
                           withObject:request
                        waitUntilDone:NO];
}

#pragma mark - Interstitial

- (void)showInterstitial
{
    // Must have been created with initInterstitial.
    if (self.placementType != MASTAdViewPlacementTypeInterstitial)
        return;

    // If the expand window isn't hidden, then the interstitial is up.
    if (self.modalViewController.view.superview != nil)
        return;
    
    [self presentModalView:self.expandView];
    
    [self performAdTracking];
    
    if ((self.mraidBridge != nil) && (self.webView.isLoading == NO))
    {
        [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateDefault];
        [self.mraidBridge setState:MASTMRAIDBridgeStateDefault forWebView:self.webView];
    }
    
    [self prepareCloseButton];
}

- (void)showInterstitialWithDuration:(NSTimeInterval)delay
{
    if (self.placementType != MASTAdViewPlacementTypeInterstitial)
        return;
    
    if (self.modalViewController.view.superview != nil)
        return;
    
    [self showInterstitial];
    
    // Cancel the interstitial timer.
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
    }
    
    // Create the interstitial timer that will close the interstial when it triggers.
    self.interstitialTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:delay]
                                                      interval:0
                                                        target:self
                                                      selector:@selector(closeInterstitial)
                                                      userInfo:nil
                                                       repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.interstitialTimer forMode:NSDefaultRunLoopMode];
}

- (void)closeInterstitial
{
    // Cancel the interstitial timer.
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
    }
    
    if (self.placementType != MASTAdViewPlacementTypeInterstitial)
        return;
    
    if (self.modalViewController.view.superview == nil)
        return;
    
    [self dismissModalView:self.expandView animated:YES];
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateHidden];
        [self.mraidBridge setState:MASTMRAIDBridgeStateHidden forWebView:self.webView];
    }
}

#pragma mark - Internal Browser

- (BOOL)isInternalBrowserOpen
{
    return [self adBrowserOpen];
}

- (MASTAdBrowser*)adBrowser
{
    if (adBrowser == nil)
    {
        adBrowser = [MASTAdBrowser new];
        adBrowser.delegate = self;
    }
    
    return adBrowser;
}

- (BOOL)adBrowserOpen
{
    if (adBrowser == nil)
        return NO;
    
    if (adBrowser.view.superview == nil)
        return NO;
    
    return YES;
}

- (void)openAdBrowserWithURL:(NSURL*)url
{
    self.adBrowser.view.frame = self.modalViewController.view.bounds;
    
    self.adBrowser.URL = url;
    
    [self invokeDelegateSelector:@selector(MASTAdViewInternalBrowserWillOpen:)];
    
    [self presentModalView:self.adBrowser.view];
    
    [self invokeDelegateSelector:@selector(MASTAdViewInternalBrowserDidOpen:)];
}

- (void)closeAdBrowser
{
    [self invokeDelegateSelector:@selector(MASTAdViewInternalBrowserWillClose:)];
    
    [self dismissModalView:self.adBrowser.view animated:YES];
    self.adBrowser = nil;

    [self resumeUpdates];
    
    [self invokeDelegateSelector:@selector(MASTAdViewInternalBrowserDidClose:)];
}

- (void)MASTAdBrowser:(MASTAdBrowser *)browser didFailLoadWithError:(NSError *)error
{
    [self logEvent:[NSString stringWithFormat:@"Internal browser unable to load content.: %@", [error description]]
            ofType:MASTAdViewLogEventTypeError
              func:__func__
              line:__LINE__];
}

- (void)MASTAdBrowserClose:(MASTAdBrowser *)browser
{
    // Delay to workaround issues with iOS5 not implementing isBeingPresented
    // as expected (and as-is in iOS6).
    [self performSelector:@selector(closeAdBrowser) withObject:nil afterDelay:0.5];
}

- (void)MASTAdBrowserWillLeaveApplication:(MASTAdBrowser*)browser
{
    [self invokeDelegateSelector:@selector(MASTAdViewWillLeaveApplication:)];
    
    self.skipNextUpdateTick = YES;
    
    // Delay to workaround issues with iOS5 not implementing isBeingPresented
    // as expected (and as-is in iOS6).
    [self performSelector:@selector(closeAdBrowser) withObject:nil afterDelay:0.5];
}

#pragma mark - Gestures

- (void)tapGesture:(id)sender
{
    // Taps are only handled directly for imageView and labelView based ads.
    // Any web based ad MUST implement it's own navigation
    if ((self.imageView.superview == nil) && (self.labelView.superview == nil))
        return;
    
    if ([[self.adDescriptor url] length] == 0)
        return;
    
    NSURL* url = [NSURL URLWithString:self.adDescriptor.url];
    
    __block BOOL shouldOpen = YES;
    if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldOpenURL:)])
    {
        [self invokeDelegateBlock:^
        {
            shouldOpen = [self.delegate MASTAdView:self shouldOpenURL:url];
        }];
    }
    
    if (shouldOpen == NO)
        return;
    
    if (self.useInternalBrowser)
    {
        [self openAdBrowserWithURL:url];
        return;
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.closeButton)
        return NO;
    
    return YES;
}

#pragma mark - Window containers

- (UIViewController*)modalViewController
{
    if (modalViewController == nil)
    {
        modalViewController = [MASTModalViewController new];
        modalViewController.delegate = self;
    }
    
    return modalViewController;
}

- (BOOL)presentingModalView
{
    if (self.modalViewController.view.superview != nil)
         return YES;
    
    return NO;
}

- (void)presentModalView:(UIView*)view
{
    [self.modalViewController.view addSubview:view];
    
    if (self.modalViewController.view.superview == nil)
    {
        self.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        
        UIViewController* rootViewController = [self modalRootViewController];
        
        if (rootViewController == nil)
        {
            [self logEvent:@"Unable to present modal view controller becuase rootViewController is nil.  Be sure to set the keyWindow's rootViewController or provide one with MASTAdViewPResentionController:."
                    ofType:MASTAdViewLogEventTypeError
                      func:__func__
                      line:__LINE__];

            return;
        }
        
        if (self.statusBarHidden == NO)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        
        if ([rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            self.modalDismissAfterPresent = NO;
            
            [rootViewController presentViewController:self.modalViewController animated:YES completion:^()
            {
                if (self.modalDismissAfterPresent)
                {
                    [self dismissModalView:view animated:YES];
                }
            }];
        }
        else
        {
            [rootViewController presentModalViewController:self.modalViewController animated:YES];
        }
    }
}

- (void)dismissModalView:(UIView*)view animated:(BOOL)animated
{
    if (self.modalViewController.view.superview == nil)
        return;
    
    if ([self.modalViewController respondsToSelector:@selector(isBeingPresented)])
    {
        if ([self.modalViewController isBeingPresented])
        {
            self.modalDismissAfterPresent = YES;
            return;
        }
    }
    
    if ([view superview] == self.modalViewController.view)
        [view removeFromSuperview];
    
    if ([self.modalViewController.view.subviews count] > 0)
        return;
    
    if (self.statusBarHidden == NO)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if ([self.modalViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self.modalViewController dismissViewControllerAnimated:animated completion:nil];
    }
    else
    {
        [self.modalViewController dismissModalViewControllerAnimated:animated];
    }
}

- (UIViewController*)modalRootViewController
{
    UIViewController* rootViewController = [self.window rootViewController];
    
    if (rootViewController == nil)
    {
        rootViewController = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController];
    }
    
    if (rootViewController == nil)
    {
        rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    
    if ([self.delegate respondsToSelector:@selector(MASTAdViewPresentationController:)])
    {
        rootViewController = [self.delegate MASTAdViewPresentationController:self];
    }
    
    return rootViewController;
}

#pragma mark - MASTModalViewControllerDelegate

- (void)MASTModalViewControllerDidRotate:(MASTModalViewController*)controller
{
    UIInterfaceOrientation interfaceOrientation = controller.interfaceOrientation;
    
    NSInteger degrees = 0;
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            degrees = 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            degrees = -90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            degrees = 90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            degrees = 180;
            break;
    }
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
    
    // Workaround for pre-iOS 5 UIWebView not telling JS about the change.
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 5)
    {
        NSString* script = [NSString stringWithFormat:@"window.__defineGetter__('orientation',function(){return %i;});", degrees];
        
        script = [script stringByAppendingString:@"(function(){var event = document.createEvent('Events'); event.initEvent('orientationchange',true, false); window.dispatchEvent(event);})();"];
        
        [self.webView stringByEvaluatingJavaScriptFromString:script];
    }
}

#pragma mark - Native containers

- (UILabel*)labelView
{
    if (labelView == nil)
    {
        labelView = [[UILabel alloc] initWithFrame:self.bounds];
        labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        labelView.numberOfLines = 4;
        labelView.textAlignment = UITextAlignmentCenter;
        labelView.minimumFontSize = 10;
        labelView.adjustsFontSizeToFitWidth = YES;
        labelView.backgroundColor = self.backgroundColor;
        labelView.textColor = [UIColor blueColor];
        labelView.opaque = YES;
        labelView.userInteractionEnabled = NO;
        labelView.autoresizesSubviews = YES;
    }
    
    return labelView;
}

- (UIImageView*)imageView
{
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = self.backgroundColor;
        imageView.opaque = YES;
        imageView.userInteractionEnabled = NO;
        imageView.autoresizesSubviews = YES;
    }
    
    return imageView;
}

- (UIWebView*)webView
{
    if (webView == nil)
    {
        webView = [[UIWebView alloc] initWithFrame:self.bounds];
        webView.delegate = self;
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.autoresizesSubviews = YES;
        webView.mediaPlaybackRequiresUserAction = NO;
        webView.allowsInlineMediaPlayback = YES;
        
        //[webView disableScrolling];
        [webView disableSelection];
    }
    
    return webView;
}

- (UIView*)expandView
{
    if (expandView == nil)
    {
        expandView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        expandView.autoresizesSubviews = YES;
        expandView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        expandView.backgroundColor = [UIColor blackColor];
        expandView.opaque = YES;
        expandView.userInteractionEnabled = YES;
    }
    
    return expandView;
}

- (UIView*)resizeView
{
    if (resizeView == nil)
    {
        resizeView = [[UIView alloc] initWithFrame:CGRectZero];
        resizeView.backgroundColor = [UIColor clearColor];
        resizeView.opaque = NO;
        resizeView.autoresizesSubviews = YES;
        resizeView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    return resizeView;
}

#pragma mark - Resize View Container

- (UIView*)resizeViewSuperview
{
    UIView* resizeViewSuperview = [[[self window] rootViewController] view];
    
    if (resizeViewSuperview == nil)
    {
        resizeViewSuperview = [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view];
    }

    if (resizeViewSuperview == nil)
    {
        resizeViewSuperview = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    }

    if ([self.delegate respondsToSelector:@selector(MASTAdViewRichMediaResizeSuperview:)])
    {
        resizeViewSuperview = [self.delegate MASTAdViewResizeSuperview:self];
    }
    
    return resizeViewSuperview;
}

- (CGRect)resizeViewMaxRect
{
    CGSize screenSize = [self screenSizeIncludingStatusBar:NO];
    CGRect maxRect = [self resizeViewSuperview].bounds;
    
    // Only account for the status bar size if the maxSize is the screen size.
    // This would be the case where the resize superview is the rootViewController's
    // view or the like.  It also works around the case where the resize superview may
    // be this view's superview which may already account for the status bar.
    
    if (CGSizeEqualToSize(maxRect.size, screenSize))
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        if (CGRectEqualToRect(statusBarFrame, CGRectZero) == NO)
        {
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            {
                maxRect.origin.y += statusBarFrame.size.height;
                maxRect.size.height -= statusBarFrame.size.height;
            }
            else
            {
                maxRect.origin.y += statusBarFrame.size.width;
                maxRect.size.height -= statusBarFrame.size.width;
            }
        }
    }
    
    return maxRect;
}

#pragma mark - Close Button

- (void)showCloseButton:(BOOL)showCloseButton afterDelay:(NSTimeInterval)delay
{
    if (showCloseButton == NO)
    {
        self.closeButtonTimeInterval = -1;
        return;
    }
    
    self.closeButtonTimeInterval = delay;
    
    [self prepareCloseButton];
}

- (void)prepareCloseButton
{
    [self.closeButtonTimer invalidate];
    [self.closeButton removeFromSuperview];
    
    if (self.mraidBridge != nil)
    {
        switch (self.mraidBridge.state)
        {
            case MASTMRAIDBridgeStateDefault:
                if (self.placementType == MASTMRAIDBridgePlacementTypeInterstitial)
                {
                    if (self.mraidBridge.expandProperties.useCustomClose == NO)
                    {
                        [self showCloseButton];
                    }
                }
                break;
                
            case MASTMRAIDBridgeStateExpanded:
                // When expanded use the built in button or the custom one, else nothing else.
                if (self.mraidBridge.expandProperties.useCustomClose == NO)
                {
                    [self showCloseButton];
                }
                return;
                
            case MASTMRAIDBridgeStateResized:
                // The ad creative MUST supply it's own close button.
                return;
                
            default:
                break;
        }
    }
    
    if (self.closeButtonTimeInterval < 0)
        return;
    
    if (self.closeButtonTimeInterval == 0)
    {
        [self showCloseButton];
        return;
    }
    
    self.closeButtonTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.closeButtonTimeInterval]
                                                     interval:0
                                                       target:self
                                                     selector:@selector(showCloseButton)
                                                     userInfo:nil
                                                      repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.closeButtonTimer forMode:NSDefaultRunLoopMode];
}

- (void)showCloseButton
{
    __block UIButton* customButton = nil;
    
    if ([self.delegate respondsToSelector:@selector(MASTAdViewCustomCloseButton:)])
    {
        [self invokeDelegateBlock:^
        {
            customButton = [self.delegate MASTAdViewCustomCloseButton:self];
        }];
    }
    self.closeButton = customButton;
    
    if (customButton == nil)
    {
        // TODO: Cache image/data.
        NSData* buttonData = [NSData dataWithBytesNoCopy:MASTCloseButton_png
                                                  length:MASTCloseButton_png_len
                                            freeWhenDone:NO];
        
        UIImage* buttonImage = [UIImage imageWithData:buttonData];

        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:buttonImage forState:UIControlStateNormal];

        self.closeButton.frame = CGRectMake(0, 0, 36, 36);
    }
    
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // Rest the adview as a target so that only one target for the adview
    // exists (if multiples for the same selector and target can even exist).
    [self.closeButton removeTarget:self 
                            action:nil 
                  forControlEvents:UIControlEventAllEvents];
    
    
    [self.closeButton addTarget:self
                         action:@selector(closeControlEvent:)
               forControlEvents:UIControlEventTouchUpInside];
    
    if (self.mraidBridge != nil)
    {
        switch (self.mraidBridge.state)
        {
            case MASTMRAIDBridgeStateLoading:
            case MASTMRAIDBridgeStateDefault:
            case MASTMRAIDBridgeStateHidden:
                // Like text or image ads just put the close button at the top of the stack
                // on the ad view and not on the webview.
                break;
                
            case MASTMRAIDBridgeStateExpanded:
                // In this state add the button to the close control for expand.
                [self.expandCloseControl addSubview:self.closeButton];
                self.closeButton.center = CGPointMake(CGRectGetMidX(self.expandCloseControl.bounds),
                                                      CGRectGetMidY(self.expandCloseControl.bounds));
                // Done with showing it.
                return;
                
            case MASTMRAIDBridgeStateResized:
                // In this state add the button to the close control for resize.
                [self.resizeCloseControl addSubview:self.closeButton];
                self.closeButton.center = CGPointMake(CGRectGetMidX(self.resizeCloseControl.bounds),
                                                      CGRectGetMidY(self.resizeCloseControl.bounds));
                
                // Done with showing it.
                return;
        }
    }
    
    switch (self.placementType)
    {
        case MASTAdViewPlacementTypeInline:
        {
            // Place in top right.
            CGRect frame = self.closeButton.frame;
            frame.origin.x = CGRectGetMaxX(self.bounds) - frame.size.width - frame.size.width/2;
            frame.origin.y = CGRectGetMinY(self.bounds) + frame.size.width/2;
            self.closeButton.frame = frame;
            [self addSubview:self.closeButton];
            [self bringSubviewToFront:self.closeButton];
            break;
        }

        case MASTAdViewPlacementTypeInterstitial:
        {
            // Place in top right.
            CGRect frame = self.closeButton.frame;
            frame.origin.x = CGRectGetMaxX(self.expandView.bounds) - frame.size.width - frame.size.width/2;;
            frame.origin.y = CGRectGetMinY(self.expandView.bounds) + frame.size.width/2;
            self.closeButton.frame = frame;
            [self.expandView addSubview:self.closeButton];
            [self.expandView bringSubviewToFront:self.closeButton];
            break;
        }
    }
}

#pragma mark - Control Handling

- (UIControl*)expandCloseControl
{
    if (expandCloseControl == nil)
    {
        CGRect closeControlFrame = CGRectMake(0, 0, 50, 50);
        expandCloseControl = [[UIControl alloc] initWithFrame:closeControlFrame];
        
        expandCloseControl.backgroundColor = [UIColor clearColor];
        expandCloseControl.opaque = NO;
        
        expandCloseControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
            UIViewAutoresizingFlexibleBottomMargin;
        
        [expandCloseControl addTarget:self 
                               action:@selector(closeControlEvent:) 
                     forControlEvents:UIControlEventTouchUpInside];
    }
    
    return expandCloseControl;
}

- (UIControl*)resizeCloseControl
{
    if (resizeCloseControl == nil)
    {
        CGRect closeControlFrame = CGRectMake(0, 0, 50, 50);
        resizeCloseControl = [[UIControl alloc] initWithFrame:closeControlFrame];
        resizeCloseControl.backgroundColor = [UIColor clearColor];
        resizeCloseControl.opaque = NO;
        
        [resizeCloseControl addTarget:self 
                               action:@selector(closeControlEvent:) 
                     forControlEvents:UIControlEventTouchUpInside];
    }
    
    return resizeCloseControl;
}

- (void)closeControlEvent:(id)sender
{
    if (self.mraidBridge != nil)
    {
        switch (self.mraidBridge.state)
        {
            case MASTMRAIDBridgeStateLoading:
            case MASTMRAIDBridgeStateDefault:
            case MASTMRAIDBridgeStateHidden:
                // In these states this event should never ever occur, however let
                // control drop through so that the delegate can be invoked.
                break;

            case MASTMRAIDBridgeStateExpanded:
            case MASTMRAIDBridgeStateResized:
                // Handle as if the close request came from the mraid bridge.
                [self mraidBridgeClose:self.mraidBridge];
                
                // Nothing else to do here and don't send the event to the
                // delegate below.
                return;
        }
    }
    
    // If it's not MRAID then nothing to do but notify the delegate.
    [self invokeDelegateSelector:@selector(MASTAdViewCloseButtonPressed:)];
}

#pragma mark - Resetting

- (void)resetImageAd
{
    [self.imageView setImages:nil withDurations:nil];
    [self.imageView removeFromSuperview];
}

- (void)resetTextAd
{
    [self.labelView setText:nil];
    [self.labelView removeFromSuperview];
}

- (void)resetWebAd
{
    [self.mraidBridge setDelegate:nil];
    self.mraidBridge = nil;
    
    [self.webView removeFromSuperview];
    [self.webView stopLoading];
}

#pragma mark - Image Ad Handling

// Main thread
- (void)renderImageAd:(id)imageArg
{
    self.imageView.frame = self.bounds;
    
    if ([imageArg isKindOfClass:[UIImage class]])
    {
        self.imageView.image = imageArg;
    }
    else
    {
        [self.imageView setImages:[imageArg objectAtIndex:0]
                    withDurations:[imageArg objectAtIndex:1]];
    }
    
    switch (self.placementType)
    {
        case MASTAdViewPlacementTypeInline:
            [self addSubview:self.imageView];
            break;
            
        case MASTAdViewPlacementTypeInterstitial:
            self.imageView.frame = self.expandView.bounds;
            [self.expandView addSubview:self.imageView];
            break;
    }
    
    [self resetWebAd];
    [self resetTextAd];
    
    [self prepareCloseButton];
    [self performAdTracking];
    
    [self invokeDelegateSelector:@selector(MASTAdViewDidRecieveAd:)];
}

// Background thread
- (void)loadImageAd:(MASTMoceanAdDescriptor*)ad
{
    @autoreleasepool
    {
        NSError* error = nil;
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:ad.img]
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:MAST_DEFAULT_NETWORK_TIMEOUT];
        
        [request setValue:AdViewUserAgent forHTTPHeaderField:MASTUserAgentHeader];
        
        NSURLResponse* response = nil;
        NSData* imageData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:nil];
        
        if ((imageData == nil) || (error != nil))
        {
            if (error == nil)
                error = [NSError errorWithDomain:@"Image download failure." code:0 userInfo:nil];
            
            if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
            {
                [self invokeDelegateBlock:^
                 {
                     [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
                 }];
            }
            
            return;
        }

        // This can be either a single image to render or a array with two elements,
        // the first the list of images and the second a list of intervals.
        id renderImageArg = nil;
        
        if (memcmp(imageData.bytes, "GIF89a", 6) == 0)
        {
            CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
            
            size_t imageSourceRefCount = CGImageSourceGetCount(imageSourceRef);
            if (imageSourceRefCount > 1)
            {
                NSMutableArray* delayImages = [NSMutableArray new];
                NSMutableArray* delayIntervals = [NSMutableArray new];
                
                for (int i = 0; i < imageSourceRefCount; ++i)
                {
                    // Fetch the image.
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, i, NULL);
                    UIImage* image = [UIImage imageWithCGImage:imageRef];
                    [delayImages addObject:image];
                    CFRelease(imageRef);
                    
                    // Fetch the delay.
                    CFDictionaryRef imagePropertiesRef = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, i, NULL);
                    NSDictionary* imageProperties = (__bridge NSDictionary*)imagePropertiesRef;
                    NSDictionary* gifProperties = [imageProperties objectForKey:(__bridge NSString*)kCGImagePropertyGIFDictionary];
                    NSTimeInterval delay = [[gifProperties objectForKey:(__bridge NSString*)kCGImagePropertyGIFUnclampedDelayTime] doubleValue];
                    if (delay <= 0)
                        delay = .10;
                    [delayIntervals addObject:[NSNumber numberWithFloat:delay]];
                    CFRelease(imagePropertiesRef);
                }
                
                renderImageArg = [NSArray arrayWithObjects:delayImages, delayIntervals, nil];
            }

            CFRelease(imageSourceRef);
        }
        
        if (renderImageArg == nil)
        {
            renderImageArg = [UIImage imageWithData:imageData];
        }
        
        self.adDescriptor = ad;
        [self performSelectorOnMainThread:@selector(renderImageAd:) withObject:renderImageArg waitUntilDone:NO];
    }
}

#pragma mark - Text Ad Handling

// Main thread
- (void)renderTextAd:(NSString*)text
{
    self.labelView.frame = self.bounds;
    self.labelView.text = text;
    
    switch (self.placementType)
    {
        case MASTAdViewPlacementTypeInline:
            [self addSubview:self.labelView];
            break;
            
        case MASTAdViewPlacementTypeInterstitial:
            self.labelView.frame = self.expandView.bounds;
            [self.expandView addSubview:self.labelView];
            break;
    }
    
    [self resetWebAd];
    [self resetImageAd];
    
    [self prepareCloseButton];
    [self performAdTracking];
    
    [self invokeDelegateSelector:@selector(MASTAdViewDidRecieveAd:)];
}

#pragma mark - MRAID Ad Handling

// Main thread
- (void)renderMRAIDAd:(id)mraidFragmentOrTwoPartRequest
{
    self.invokeTracking = NO;
    
    [self.webView stopLoading];
    
    if (registerProtocolClass)
    {
        registerProtocolClass = NO;
        [NSURLProtocol registerClass:[MASTURLProtocol class]];
    }

    self.mraidBridge = [MASTMRAIDBridge new];
    self.mraidBridge.delegate = self;
    
    switch (self.placementType)
    {
        case MASTAdViewPlacementTypeInline:
            [self addSubview:self.webView];
            break;
            
        case MASTAdViewPlacementTypeInterstitial:
            self.webView.frame = self.expandView.bounds;
            [self.expandView addSubview:self.webView];
            break;
    }
    
    if (self.isExpandedURL == NO)
    {
        NSString* htmlContent = [NSString stringWithFormat:MAST_RICHMEDIA_FORMAT, (NSString*)mraidFragmentOrTwoPartRequest];
        [self.webView loadHTMLString:htmlContent baseURL:nil];
    }
    else
    {
        [self.webView loadRequest:(NSURLRequest*)mraidFragmentOrTwoPartRequest];
    }
    
    [self resetImageAd];
    [self resetTextAd];
    
    [self invokeDelegateSelector:@selector(MASTAdViewDidRecieveAd:)];
}

// UIWebView callback thread
- (void)mraidSupports:(UIWebView*)wv
{
    // SMS defaults to availability if developer doesn't implement check.
    __block BOOL smsAvailable = [MFMessageComposeViewController canSendText];
    if (smsAvailable && ([self.delegate respondsToSelector:@selector(MASTAdViewSupportsSMS:)] == YES))
    {
        [self invokeDelegateBlock:^
        {
             smsAvailable = [self.delegate MASTAdViewSupportsSMS:self];
        }];
    }
    
    // Phone defaults to availability if developer doesn't implement check.
    __block BOOL phoneAvailable = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]];
    if (phoneAvailable && ([self.delegate respondsToSelector:@selector(MASTAdViewSupportsPhone:)] == YES))
    {
        [self invokeDelegateBlock:^
        {
            phoneAvailable = [self.delegate MASTAdViewSupportsPhone:self];
        }];
    }
    
    // Calendar defaults to disabled if check not implemented by developer.
    __block BOOL calendarAvailable = [self.delegate respondsToSelector:@selector(MASTAdViewSupportsCalendar:)];
    if (calendarAvailable)
    {
        // For iOS 6 and later check if the application has authorization to use the calendar.
        if ([EKEventStore respondsToSelector:@selector(authorizationStatusForEntityType:)])
        {
            if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] != EKAuthorizationStatusAuthorized)
            {
                calendarAvailable = NO;
            }
        }
        
        if (calendarAvailable)
        {
            [self invokeDelegateBlock:^
            {
                calendarAvailable = [self.delegate MASTAdViewSupportsCalendar:self];
            }];
        }
    }
    
    // Store picture defaults to disabled if check not implemented by developer.
    __block BOOL storePictureAvailable = [self.delegate respondsToSelector:@selector(MASTAdViewSupportsStorePicture:)];
    if (storePictureAvailable)
    {
        [self invokeDelegateBlock:^
        {
            storePictureAvailable = [self.delegate MASTAdViewSupportsStorePicture:self];
        }];
    }
    
    [self.mraidBridge setSupported:smsAvailable forFeature:MASTMRAIDBridgeSupportsSMS forWebView:wv];
    [self.mraidBridge setSupported:phoneAvailable forFeature:MASTMRAIDBridgeSupportsTel forWebView:wv];
    [self.mraidBridge setSupported:calendarAvailable forFeature:MASTMRAIDBridgeSupportsCalendar forWebView:wv];
    [self.mraidBridge setSupported:storePictureAvailable forFeature:MASTMRAIDBridgeSupportsStorePicture forWebView:wv];
    
    [self.mraidBridge setSupported:YES forFeature:MASTMRAIDBridgeSupportsInlineVideo forWebView:wv];
}

- (void)mraidInitializeBridge:(MASTMRAIDBridge*)bridge forWebView:(UIWebView*)wv
{
    @synchronized (bridge)
    {
        if (bridge.needsInit == NO)
            return;
        
        if (wv.isLoading)
            return;
        
        bridge.needsInit = NO;
    }
    
    [self mraidSupports:self.webView];
    
    MASTMRAIDBridgePlacementType mraidPlacementType = MASTMRAIDBridgePlacementTypeInline;
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
    {
        mraidPlacementType = MASTMRAIDBridgePlacementTypeInterstitial;
    }
    [bridge setPlacementType:mraidPlacementType forWebView:self.webView];
    
    [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateDefault];
    
    CGSize screenSize = [self screenSizeIncludingStatusBar:NO];
    MASTMRAIDExpandProperties* expandProperties = [[MASTMRAIDExpandProperties alloc] initWithSize:screenSize];
    [bridge setExpandProperties:expandProperties forWebView:self.webView];
    
    MASTMRAIDResizeProperties* resizeProperties = [MASTMRAIDResizeProperties new];
    [bridge setResizeProperties:resizeProperties forWebView:self.webView];
    
    MASTMRAIDOrientationProperties* orientationProperties = [MASTMRAIDOrientationProperties new];
    [bridge setOrientationProperties:orientationProperties forWebView:self.webView];
    
    if (self.isExpandedURL == NO)
    {
        [self.mraidBridge setState:MASTMRAIDBridgeStateDefault forWebView:self.webView];
    }
    else
    {
        [self mraidBridge:self.mraidBridge expandWithURL:nil];
    }
    
    [bridge sendReadyForWebView:self.webView];
    
    [self prepareCloseButton];
}

- (void)mraidUpdateLayoutForNewState:(MASTMRAIDBridgeState)state
{
    CGSize screenSize = [self screenSizeIncludingStatusBar:NO];
    CGRect defaultFrame = [self absoluteFrameForView:self];
    CGRect currentFrame = [self absoluteFrameForView:self.webView];
    
    CGSize maxSize = [self resizeViewMaxRect].size;
    
    BOOL viewable = NO;
    
    if (self.placementType == MASTAdViewPlacementTypeInline)
    {
        if (state == MASTMRAIDBridgeStateExpanded)
        {
            // This doesn't take any consideration to the app being suspended (and obviously terminated).
            viewable = YES;
        }
        else
        {
            if (self.window != nil)
            {
                if (self.hidden == NO)
                {
                    if (CGRectIntersectsRect(CGRectMake(0, 0, maxSize.width, maxSize.height), currentFrame))
                    {
                        viewable = YES;
                    }
                }
            }
        }
    }
    else
    {
        maxSize = screenSize;
        defaultFrame = CGRectMake(0, 0, maxSize.width, maxSize.height);
        currentFrame = CGRectZero;
        
        if (self.modalViewController.view.superview != nil)
        {
            viewable = YES;
            currentFrame = [self absoluteFrameForView:self.webView];
        }
    }
    
    if ([self adBrowserOpen])
    {
        // When the browser is up, it's modal and even expanded ads are covered.
        viewable = NO;
    }
    
    [self.mraidBridge setScreenSize:screenSize forWebView:self.webView];
    [self.mraidBridge setMaxSize:maxSize forWebView:self.webView];
    [self.mraidBridge setDefaultPosition:defaultFrame forWebView:self.webView];
    [self.mraidBridge setCurrentPosition:currentFrame forWebView:self.webView];
    [self.mraidBridge setViewable:viewable forWebView:self.webView];
}

#pragma mark - MASTMRAIDBridgeDelegate

- (void)mraidBridgeInit:(MASTMRAIDBridge *)bridge
{
    bridge.needsInit = YES;
    
    [self mraidInitializeBridge:bridge forWebView:self.webView];
}

- (void)mraidBridgeClose:(MASTMRAIDBridge*)bridge
{
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
    {
        [self invokeDelegateSelector:@selector(MASTAdViewCloseButtonPressed:)];
        return;
    }
    
    switch (bridge.state)
    {
        case MASTMRAIDBridgeStateLoading:
        case MASTMRAIDBridgeStateHidden:
            // Nothing to close.
            return;
            
        case MASTMRAIDBridgeStateDefault:
            // MRAID leaves this open ended on the SDK so ignoring the request.
            break;
            
        case MASTMRAIDBridgeStateExpanded:
        {
            [self invokeDelegateSelector:@selector(MASTAdViewWillCollapse:)];
            
            if (self.expandedAdView != nil)
            {
                [self.expandedAdView mraidBridgeClose:self.expandedAdView.mraidBridge];
                self.expandedAdView = nil;
            }
            
            // Put the webview back on the base ad view (self).
            [self.webView setFrame:self.bounds];
            [self addSubview:self.webView];
            
            [self.webView scrollToTop];
            
            [self prepareCloseButton];
            
            [self dismissModalView:self.expandView animated:YES];
            
            [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateDefault];
            [self.mraidBridge setState:MASTMRAIDBridgeStateDefault forWebView:self.webView];

            [self invokeDelegateSelector:@selector(MASTAdViewDidCollapse:)];
            
            [self resumeUpdates];

            break;
        }

        case MASTMRAIDBridgeStateResized:
        {
            [self invokeDelegateSelector:@selector(MASTAdViewWillCollapse:)];
            
            [self.webView setFrame:self.bounds];
            [self addSubview:self.webView];
            
            [self.resizeView removeFromSuperview];
            
            [self.webView scrollToTop];
            
            [self prepareCloseButton];
            
            [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateDefault];
            [self.mraidBridge setState:MASTMRAIDBridgeStateDefault forWebView:self.webView];
            
            [self invokeDelegateSelector:@selector(MASTAdViewDidCollapse:)];
            
            [self resumeUpdates];
            break;
        }
    }
}

- (void)mraidBridge:(MASTMRAIDBridge *)bridge openURL:(NSString*)url
{
    __block BOOL shouldOpen = YES;
    if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldOpenURL:)])
    {
        [self invokeDelegateBlock:^
        {
            shouldOpen = [self.delegate MASTAdView:self shouldOpenURL:[NSURL URLWithString:url]];
        }];
    }
    
    if (shouldOpen == NO)
        return;
    
    if (self.useInternalBrowser)
    {
        [self openAdBrowserWithURL:[NSURL URLWithString:url]];
        
        return;
    }
    
    [self invokeDelegateSelector:@selector(MASTAdViewWillLeaveApplication:)];
    
    self.skipNextUpdateTick = YES;

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)mraidBridgeUpdateCurrentPosition:(MASTMRAIDBridge*)bridge
{
    [self mraidUpdateLayoutForNewState:bridge.state];
}

- (void)mraidBridgeUpdatedExpandProperties:(MASTMRAIDBridge*)bridge
{
    if ((bridge.state == MASTMRAIDBridgeStateExpanded) ||
        ((self.placementType == MASTAdViewPlacementTypeInterstitial) && (bridge.state == MASTMRAIDBridgeStateDefault)))
    {
        [self prepareCloseButton];
    }
}

- (void)mraidBridge:(MASTMRAIDBridge*)bridge expandWithURL:(NSString*)url
{
    BOOL hasURL = [url length] != 0;
    
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
    {
        [bridge sendErrorMessage:@"Can not expand with placementType interstitial."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    switch (bridge.state)
    {
        case MASTMRAIDBridgeStateLoading:
            // If loading and not an expanded URL, do nothing.
            if (self.isExpandedURL == NO)
                return;
            break;

        case MASTMRAIDBridgeStateHidden:
            // Expand from these existing states is a no-op.
            return;
            
        case MASTMRAIDBridgeStateExpanded:
            // Can not expand from the expanded state.
            return;
            
        default:
            // From default or resized the ad can expand.
            break;
    }
    
    // If there's a URL then use the expandedAdView (a different container) to 
    // render the ad and just update the state of the current ad to expanded.
    if (hasURL)
    {
        self.expandedAdView = [MASTAdView new];
        [self.expandedAdView showExpanded:url];
        
        [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateExpanded];
        
        return;
    }
    
    [self invokeDelegateSelector:@selector(MASTAdViewWillExpand:)];
    
    // Reset the exanded view's frame.
    self.expandView.frame = self.modalViewController.view.bounds;

    // Move the webView to the expandView and update it's frame to match.
    [self.expandView addSubview:self.webView];
    [self.webView setFrame:self.expandView.bounds];
    
    [self.webView scrollToTop];
    
    [self presentModalView:self.expandView];
    
    [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateExpanded];
    [bridge setState:MASTMRAIDBridgeStateExpanded forWebView:self.webView];
    
    // Setup the "guaranteed" close area (invisible).
    CGRect closeControlFrame = CGRectMake(CGRectGetMaxX(self.expandView.bounds) - 50,
                                          CGRectGetMinY(self.expandView.bounds), 
                                          50, 50);
    self.expandCloseControl.frame = closeControlFrame;
    
    [self.expandView addSubview:self.expandCloseControl];
    
    [self prepareCloseButton];
    
    [self invokeDelegateSelector:@selector(MASTAdViewDidExpand:)];
}

- (void)mraidBridgeUpdatedOrientationProperties:(MASTMRAIDBridge *)bridge
{
    self.modalViewController.allowRotation = bridge.orientationProperties.allowOrientationChange;
    
    if ((bridge.state == MASTMRAIDBridgeStateExpanded) ||
        ((self.placementType == MASTAdViewPlacementTypeInterstitial) && (bridge.state == MASTMRAIDBridgeStateDefault)))
    {
        switch (bridge.orientationProperties.forceOrientation)
        {
            case MASTMRAIDOrientationPropertiesForceOrientationPortrait:
                [self.modalViewController forceRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                break;
                
            case MASTMRAIDOrientationPropertiesForceOrientationLandscape:
                [self.modalViewController forceRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                break;
                
            case MASTMRAIDOrientationPropertiesForceOrientationNone:
                break;
        }
    }
}

- (void)mraidBridgeUpdatedResizeProperties:(MASTMRAIDBridge *)bridge
{
    
}

- (void)mraidBridgeResize:(MASTMRAIDBridge*)bridge
{
    UIView* resizeViewSuperview = [self resizeViewSuperview];
    
    if (resizeViewSuperview == nil)
    {
        [bridge sendErrorMessage:@"Unable to determine superview for resize container view."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
    {
        [bridge sendErrorMessage:@"Can not resize with placementType interstitial."
                       forAction:@"expand"
                      forWebView:self.webView];
        return;
    }
    
    switch (bridge.state)
    {
        case MASTMRAIDBridgeStateLoading:
        case MASTMRAIDBridgeStateHidden:
            // Resize from these existing states is a no-op.
            [bridge sendErrorMessage:@"Can not resize while loading or hidden."
                           forAction:@"resize"
                          forWebView:self.webView];
            return;
            
        case MASTMRAIDBridgeStateExpanded:
            // Throw an error, don't change state.
            [bridge sendErrorMessage:@"Can not resize while expanded."
                           forAction:@"resize"
                          forWebView:self.webView];
            return;
            
        case MASTMRAIDBridgeStateDefault:
        case MASTMRAIDBridgeStateResized:
            // Both of these states cause a resize though
            // a resize event doesn't 'stack' so close only
            // unwinds 'one' resize back to default.
            break;
    }
    
    CGSize requestedSize = CGSizeMake(bridge.resizeProperties.width, bridge.resizeProperties.height);
    CGPoint requestedOffset = CGPointMake(bridge.resizeProperties.offsetX, bridge.resizeProperties.offsetY);
    
    // If a size isn't available just fail.
    if (CGSizeEqualToSize(requestedSize, CGSizeZero))
    {
        [bridge sendErrorMessage:@"Size required in resizeProperties."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }
    
    CGRect maxFrame = [self resizeViewMaxRect];
    
    // The actual max size for a resize must be less than the max size reported to the bridge.
    if ((requestedSize.width >= maxFrame.size.width) && (requestedSize.height >= maxFrame.size.height))
    {
        [bridge sendErrorMessage:@"Size must be smaller than the max size."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }

    CGRect currentFrame = [resizeViewSuperview convertRect:self.bounds fromView:self];
    CGRect convertRect = currentFrame;
    
    convertRect.origin.x += requestedOffset.x;
    convertRect.origin.y += requestedOffset.y;

    convertRect.size.height = requestedSize.height;
    convertRect.size.width = requestedSize.width;
    
    if (bridge.resizeProperties.allowOffscreen == NO)
    {
        if (CGRectContainsRect(maxFrame, convertRect) == NO)
        {
            // Adjust height and width to fit.
            if (CGRectGetWidth(convertRect) > CGRectGetWidth(maxFrame))
            {
                convertRect.size.width = CGRectGetWidth(maxFrame);
            }
            if (CGRectGetHeight(convertRect) > CGRectGetHeight(maxFrame))
            {
                convertRect.size.height = CGRectGetHeight(maxFrame);
            }
            
            // Adjust X
            if (CGRectGetMinX(convertRect) < CGRectGetMinX(maxFrame))
            {
                convertRect.origin.x = CGRectGetMinX(maxFrame);
            }
            else if (CGRectGetMaxX(convertRect) > CGRectGetMaxX(maxFrame))
            {
                CGFloat diff = CGRectGetMaxX(convertRect) - CGRectGetMaxX(maxFrame);
                convertRect.origin.x -= diff;
            }
            
            // Adjust Y
            if (CGRectGetMinY(convertRect) < CGRectGetMinY(maxFrame))
            {
                convertRect.origin.y = CGRectGetMinY(maxFrame);
            }
            else if (CGRectGetMaxY(convertRect) > CGRectGetMaxY(maxFrame))
            {
                CGFloat diff = CGRectGetMaxY(convertRect) - CGRectGetMaxY(maxFrame);
                convertRect.origin.y -= diff;
            }
        }
    }
    
    const CGFloat closeControlSize = 50;
    
    // Setup the "guaranteed" close area (invisible).
    // Note, this logic only uses the width and height from  convertRect and 0,0
    // as the top left since convertRect represents the resize view frame, not bounds.
    CGRect closeControlFrame = CGRectMake(convertRect.size.width - closeControlSize, 0,
                                          closeControlSize, closeControlSize);
    
    // Unlike expand the ad can specify the general location of the control area
    switch (bridge.resizeProperties.customClosePosition)
    {
        case MASTMRAIDResizeCustomClosePositionTopRight:
            // Already configured above.
            break;
            
        case MASTMRAIDResizeCustomClosePositionTopCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2, 0,
                                           closeControlSize, closeControlSize);
            break;
            
        case MASTMRAIDResizeCustomClosePositionTopLeft:
            closeControlFrame = CGRectMake(0, 0,
                                           closeControlSize, closeControlSize);
            break;
            
        case MASTMRAIDResizeCustomClosePositionBottomLeft:
            closeControlFrame = CGRectMake(0, convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case MASTMRAIDResizeCustomClosePositionBottomRight:
            closeControlFrame = CGRectMake(convertRect.size.width - closeControlSize,
                                           convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case MASTMRAIDResizeCustomClosePositionBottomCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2,
                                           convertRect.size.height - closeControlSize,
                                           closeControlSize, closeControlSize);
            break;
            
        case MASTMRAIDResizeCustomClosePositionCenter:
            closeControlFrame = CGRectMake(convertRect.size.width/2 - closeControlSize/2,
                                           convertRect.size.height/2 - closeControlSize/2,
                                           closeControlSize, closeControlSize);
            break;
    }
    
    // Create a frame relative to the maxFrame from the closeControl frame.
    CGRect maxCloseControlFrame = closeControlFrame;
    maxCloseControlFrame.origin.x += convertRect.origin.x;
    maxCloseControlFrame.origin.y += convertRect.origin.y;
    
    // Determine if any of the close control will end up off screen.
    if (CGRectContainsRect(maxFrame, maxCloseControlFrame) == NO)
    {
        [bridge sendErrorMessage:@"Resize close control must remain on screen."
                       forAction:@"resize"
                      forWebView:self.webView];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(MASTAdView:willResizeToFrame:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate MASTAdView:self willResizeToFrame:convertRect];
        }];
    }

    self.resizeView.frame = convertRect;
    [self.resizeView addSubview:self.webView];
    [self.webView setFrame:self.resizeView.bounds];
    [resizeViewSuperview addSubview:self.resizeView];
    
    self.resizeCloseControl.frame = closeControlFrame;
    [self.resizeView addSubview:self.resizeCloseControl];
    
    // Update the bridge.
    [self mraidUpdateLayoutForNewState:MASTMRAIDBridgeStateResized];
    [bridge setState:MASTMRAIDBridgeStateResized forWebView:self.webView];
    
    if ([self.delegate respondsToSelector:@selector(MASTAdView:didResizeToFrame:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate MASTAdView:self didResizeToFrame:convertRect];
        }];
    }
}

- (void)mraidBridge:(MASTMRAIDBridge*)bridge playVideo:(NSString*)url
{
    // Default to launching the player and allow a developer to override.
    __block BOOL play = YES;
    
    if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldPlayVideo:)])
    {
        [self invokeDelegateBlock:^
        {
            play = [self.delegate MASTAdView:self shouldPlayVideo:url];
        }];
    }
    
    if (play)
    {
        [self invokeDelegateSelector:@selector(MASTAdViewWillLeaveApplication:)];
        
        self.skipNextUpdateTick = YES;
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)mraidBridge:(MASTMRAIDBridge*)bridge createCalenderEvent:(NSString*)event
{
    [self performSelectorInBackground:@selector(createCalendarEvent:) withObject:event];
}

- (void)mraidBridge:(MASTMRAIDBridge*)bridge storePicture:(NSString*)url
{
    [self performSelectorInBackground:@selector(loadAndSavePhoto:) withObject:url];
}

#pragma mark - View

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.adDescriptor == nil)
        return;
    
    if (self.placementType == MASTAdViewPlacementTypeInterstitial)
        return;
    
    [self performAdTracking];
    
    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
}

// Updates MRAID on size changes.
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    if (self.mraidBridge != nil)
    {
        [self mraidUpdateLayoutForNewState:self.mraidBridge.state];
    }
}

- (void)removeFromSuperview
{
    // To avoid NSTimer retaining instances of the MASTAdView all timers MUST be cancled when the view
    // is no longer attached to a superview.
    
    // Stop/reset the timer.
    if (self.updateTimer != nil)
    {
        [self.updateTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.updateTimer = nil;
        
        [self logEvent:@"CAUTION: removeFromSuperview invoked with live timers.  Be sure to call [MASTAdView reset] if the superview is being deallocated/destoryed and no longer referenced."
                ofType:MASTAdViewLogEventTypeError
                  func:__func__
                  line:__LINE__];
    }
    
    // Stop the interstitial timer
    if (self.interstitialTimer != nil)
    {
        [self.interstitialTimer performSelectorOnMainThread:@selector(invalidate) withObject:nil waitUntilDone:YES];
        self.interstitialTimer = nil;
        
        [self logEvent:@"CAUTION: removeFromSuperview invoked with live timers.  Be sure to call [MASTAdView reset] if the superview is being deallocated/destoryed and no longer referenced."
                ofType:MASTAdViewLogEventTypeError
                  func:__func__
                  line:__LINE__];
    }
    
    [super removeFromSuperview];
}

#pragma mark - Calendar Interactions

// Any thread
- (void)checkCalendarAuthorizationStatus
{
    if ([EKEventStore respondsToSelector:@selector(authorizationStatusForEntityType:)])
    {
        EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if (status == EKAuthorizationStatusNotDetermined)
        {
            __block BOOL calendarAvailable = [self.delegate respondsToSelector:@selector(MASTAdViewSupportsCalendar:)];
            if (calendarAvailable)
            {
                [self invokeDelegateBlock:^
                 {
                     calendarAvailable = [self.delegate MASTAdViewSupportsCalendar:self];
                 }];
            }
            
            if (calendarAvailable == NO)
            {
                return;
            }
            
            [self performSelectorInBackground:@selector(requestCalendarAuthorizationStatus) withObject:nil];
        }
    }
}

// Background thread - iOS 6 only
- (void)requestCalendarAuthorizationStatus
{
    @autoreleasepool
    {
        EKEventStore* store = [EKEventStore new];
        
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
        {
             // Result not needed.  Only needed so that EKEventStore will know the answer when asked later.
        }];
    }
}

// Background thread (Event Kit can be slow to load)
- (void)createCalendarEvent:(NSString*)jEvent
{
    @autoreleasepool
    {
        if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldSaveCalendarEvent:inEventStore:)] == NO)
        {
            [self.mraidBridge sendErrorMessage:@"Access denied."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            return;
        }
        
        NSDictionary* jDict = [NSDictionary dictionaryWithJavaScriptObject:jEvent];
        if ([jDict count] == 0)
        {
            [self.mraidBridge sendErrorMessage:@"Unable to parse event data."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            return;
        }
        
        EKEventStore* store = [[EKEventStore alloc] init];
        EKEvent* event = [EKEvent eventWithEventStore:store];
        
        NSDate* start = [NSDate dateFromW3CCalendarDate:[jDict valueForKey:@"start"]];
        if (start == nil)
            start = [NSDate date];
        
        NSDate* end = [NSDate dateFromW3CCalendarDate:[jDict valueForKey:@"end"]];
        if (end == nil)
            end = [start dateByAddingTimeInterval:3600];
        
        event.title = [jDict valueForKey:@"summary"];
        event.notes = [jDict valueForKey:@"description"];
        event.location = [jDict valueForKey:@"location"];
        event.startDate = start;
        event.endDate = end;
        
        id reminder = [jDict valueForKey:@"reminder"];
        if (reminder != nil)
        {
            EKAlarm* alarm = nil;
            
            if ([reminder isKindOfClass:[NSString class]])
            {
                NSDate* reminderDate = [NSDate dateFromW3CCalendarDate:reminder];
                if (reminderDate != nil)
                {
                    alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
                }
                else
                {
                    alarm = [EKAlarm alarmWithRelativeOffset:[reminder doubleValue] / 1000.0];
                }
            }
            
            if (alarm != nil)
            {
                [event addAlarm:alarm];
            }
        }
        
        [self invokeDelegateBlock:^
         {
             BOOL shouldSave = [self.delegate MASTAdView:self
                                 shouldSaveCalendarEvent:event
                                            inEventStore:store];
             
             UIViewController* rootViewController = [self modalRootViewController];

             // Included in this block since this block occurs on the main thread and the
             // following must be on the main thread since it's interacting with the UI.
             if (shouldSave && (rootViewController != nil))
             {
                 EKEventEditViewController* eventViewController = [EKEventEditViewController new];
                 eventViewController.eventStore = store;
                 eventViewController.event = event;
                 eventViewController.editViewDelegate = self;
                 
                 self.calendarReExpand = NO;
                 if ([self presentingModalView])
                 {
                     self.calendarReExpand = YES;
                     
                     [self dismissModalView:self.expandView animated:NO];
                 }
                 
                 if ([rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
                 {
                     [rootViewController presentViewController:eventViewController
                                                      animated:YES
                                                    completion:nil];
                 }
                 else
                 {
                     [rootViewController presentModalViewController:eventViewController
                                                           animated:YES];
                 }
                 
                 if (self.mraidBridge.state == MASTMRAIDBridgeStateExpanded)
                 {
                     // TODO: [self.expandWindow setHidden:YES];
                 }
             }
             else
             {
                 // User didn't supply a controler to present the event edit controller on.
                 [self.mraidBridge sendErrorMessage:@"Access denied."
                                          forAction:@"createCalendarEvent"
                                         forWebView:self.webView];
             }
         }];
    }
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action)
    {
        case EKEventEditViewActionCanceled:
        case EKEventEditViewActionDeleted:
        {
            [self.mraidBridge sendErrorMessage:@"User canceled."
                                     forAction:@"createCalendarEvent"
                                    forWebView:self.webView];
            break;
        }
            
        case EKEventEditViewActionSaved:
        {
            NSError* error = nil;
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            
            if (error != nil)
            {
                NSString* errorMessage = [error description];
                [self.mraidBridge sendErrorMessage:errorMessage
                                         forAction:@"createCalendarEvent"
                                        forWebView:self.webView];
                
                [self logEvent:[NSString stringWithFormat:@"Unable to save calendar event for ad: %@", errorMessage]
                        ofType:MASTAdViewLogEventTypeError
                          func:__func__
                          line:__LINE__];
            }
            break;
        }
    }
    
    UIViewController* parentViewController = [controller parentViewController];
    if (parentViewController == nil)
    {
        // This should only be possible in iOS 5 and later since parentViewController will
        // return the result.  If not though attempt to dismiss the dialog directly.
        if ([controller respondsToSelector:@selector(presentingViewController)])
        {
            parentViewController = [controller presentingViewController];
        }
        else
        {
            [controller dismissModalViewControllerAnimated:YES];
        }
    }
    
    BOOL animated = self.calendarReExpand == NO;
    
    if ([controller respondsToSelector:@selector(presentingViewController)])
    {
        [parentViewController dismissViewControllerAnimated:animated completion:nil];
    }
    else
    {
        [parentViewController dismissModalViewControllerAnimated:animated];
    }
    
    if (self.calendarReExpand)
    {
        [self presentModalView:self.expandView];
    }
}

#pragma mark - Photo Saving

// Background thread
- (void)loadAndSavePhoto:(NSString*)imageURL
{
    @autoreleasepool
    {
        if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldSavePhotoToCameraRoll:)] == NO)
        {
            return;
        }
        
        NSError* error = nil;
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]
                                                  options:NSDataReadingUncached
                                                    error:&error];
        if (error != nil)
        {
            [self.mraidBridge sendErrorMessage:error.description
                                     forAction:@"storePicture"
                                    forWebView:self.webView];
            
            [self logEvent:[NSString stringWithFormat:@"Error obtaining photo requested to save to camera roll: %@", error.description]
                    ofType:MASTAdViewLogEventTypeError
                      func:__func__
                      line:__LINE__];
            
            return;
        }
        
        UIImage* image = [UIImage imageWithData:imageData];
        
        __block BOOL save = NO;
        
        [self invokeDelegateBlock:^
         {
             save = [self.delegate MASTAdView:self shouldSavePhotoToCameraRoll:image];
         }];
        
        if (save)
        {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }
}

#pragma mark - Ad Loading

// Connection/background thread
- (void)loadContent:(NSData*)content
{
    // DEV: Use to output content of the buffered response.
    //NSString* debugString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
    //NSLog(@"loadContent: %@", debugString);
    
    MASTMoceanAdResponse* response = [[MASTMoceanAdResponse alloc] initWithXML:content];
    [response parse];
    
    if (([response.errorCode length] > 0) || ([response.adDescriptors count] == 0))
    {
        NSError* error = nil;
        
        if ([response.errorCode length] > 0)
        {
            error = [NSError errorWithDomain:response.errorMessage
                                        code:[response.errorCode integerValue]
                                    userInfo:nil];
            
            MASTAdViewLogEventType eventType = MASTAdViewLogEventTypeError;
            
            if ([@"404" isEqualToString:response.errorCode])
            {
                eventType = MASTAdViewLogEventTypeDebug;
            }

            [self logEvent:[NSString stringWithFormat:@"Error response from server. Error code: %@.  Error message: %@", response.errorCode, response.errorMessage]
                    ofType:eventType
                      func:__func__
                      line:__LINE__];
        }
        else
        {
            error = [NSError errorWithDomain:@"No ad available in response."
                                        code:0
                                    userInfo:nil];
            
            [self logEvent:error.domain
                    ofType:MASTAdViewLogEventTypeDebug
                      func:__func__
                      line:__LINE__];
        }

        if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
             }];
        }

        return;
    }
    
    MASTMoceanAdDescriptor* ad = [response.adDescriptors objectAtIndex:0];
    [self renderWithAdDescriptor:ad];
}

// Background (or main thread if called manually).
- (void)renderWithAdDescriptor:(MASTMoceanAdDescriptor*)ad
{
    self.invokeTracking = YES;
    
    if ([ad.type hasPrefix:@"image"])
    {
        // If the image can be loaded set the descriptor, else if it fails
        // don't set it so that the current image matches the current descriptor.
        [self performSelectorInBackground:@selector(loadImageAd:) withObject:ad];
        return;
    }
    
    // Text or HTML ads will load either way so update the current descsriptor.
    // TODO: Move this to where the ad descriptor is set since a no-content descriptor
    // will not actually render and the descriptor won't match the currently rendered ad.
    self.adDescriptor = ad;
    
    if ([ad.type hasPrefix:@"text"])
    {
        [self performSelectorOnMainThread:@selector(renderTextAd:) withObject:adDescriptor.text waitUntilDone:NO];
        return;
    }
    
    // For thirdparty attempt using the image or text node if a url node
    // is available else just render as richmedia/html.
    if ([ad.type hasPrefix:@"thirdparty"])
    {
        if ([self.adDescriptor.url length] > 0)
        {
            if ([self.adDescriptor.img length] > 0)
            {
                [self performSelectorInBackground:@selector(loadImageAd:) 
                                       withObject:ad];
                return;
            }
            
            if ([self.adDescriptor.text length] > 0)
            {
                [self performSelectorOnMainThread:@selector(renderTextAd:) 
                                       withObject:adDescriptor.text 
                                    waitUntilDone:NO];
                return;
            }
        }
        else
        {
            // Attempt to determine if the ad descriptor is client side since it can't be mediated.
            if ([ad.content rangeOfString:@"client_side_external_campaign"].location != NSNotFound)
            {
                MASTMoceanThirdPartyDescriptor* thirdPartyDescriptor = [[MASTMoceanThirdPartyDescriptor alloc] initWithClientSideExternalCampaign:ad.content];
                
                if ([self.delegate respondsToSelector:@selector(MASTAdView:didReceiveThirdPartyRequest:withParams:)])
                {
                    [self invokeDelegateBlock:^
                    {
                        [self.delegate MASTAdView:self
                      didReceiveThirdPartyRequest:thirdPartyDescriptor.properties
                                       withParams:thirdPartyDescriptor.params];
                    }];
                }

                return;
            }
        }
    }
    
    NSString* contentString = ad.content;
    
    if ([contentString length] == 0)
    {
        NSString* errorMessage = [NSString stringWithFormat:@"Ad descriptor missing ad content: %@", [ad description]];
        
        [self logEvent:errorMessage
                ofType:MASTAdViewLogEventTypeError
                  func:__func__
                  line:__LINE__];
        
        if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
        {
            [self invokeDelegateBlock:^
             {
                 NSError* error = [NSError errorWithDomain:errorMessage
                                                      code:0
                                                  userInfo:nil];
                 [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
             }];
        }

        return;
    }

    // All other ad types flow to the MRAID/HTML handler.
    [self performSelectorOnMainThread:@selector(renderMRAIDAd:) withObject:contentString waitUntilDone:NO];
}

#pragma mark - Tracking

- (void)performAdTracking
{
    if (self.invokeTracking)
    {
        self.invokeTracking = NO;
        
        NSString* track = self.adDescriptor.track;
        
        if ([track length] > 0)
        {
            NSURL* url = [NSURL URLWithString:track];
            
            MASTAdTracking* tracking = [[MASTAdTracking alloc] initWithURL:url
                                                                 userAgent:AdViewUserAgent];
            if (tracking == nil)
            {
                [self logEvent:[NSString stringWithFormat:@"Unable to perform ad tracking with URL: %@", track]
                        ofType:MASTAdViewLogEventTypeError
                          func:__func__
                          line:__LINE__];
            }
        }
    }
}

#pragma mark - Delegate Callbacks

// This helper is used for delegate methods that only take self as an argument and
// have a void return.
//
// Should NEVER pass a selector that may have a return object since the compiler/ARC
// may not know how to deal with the memory constraints on anything returned.  For
// delegate methods that expect to return something use the block method below and
// not this helper.
// Can be called from any thread.
- (void)invokeDelegateSelector:(SEL)selector
{
    if ([self.delegate respondsToSelector:selector])
    {
        [self invokeDelegateBlock:^
        {
            // Working around the warning until Apple fixes it.  As stated above
            // the delegate methods used here should have void return types.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:self];
            #pragma clang diagnostic pop
        }];
    }
}

// Can be called on any thread but if called on the non-main thread
// will block until the main thread executes the block.
- (void)invokeDelegateBlock:(dispatch_block_t)block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_sync(queue, block);
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* scheme = [[request URL] scheme];
    
    if ([scheme isEqualToString:@"console"])
    {
        NSString* l = [[request URL] query];
        NSString* logString = (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)l, CFSTR(""));
        
        [self logEvent:[NSString stringWithFormat:@"UIWebView console: %@", logString]
                ofType:MASTAdViewLogEventTypeDebug
                  func:__func__
                  line:__LINE__];
        
        return NO;
    }
    
    if ([scheme isEqualToString:@"mraid"])
    {
        BOOL handled = [self.mraidBridge parseRequest:request];
        
        if (handled)
        {
            return NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(MASTAdView:didProcessRichmediaRequest:)])
        {
            [self invokeDelegateBlock:^
            {
                [self.delegate MASTAdView:self didProcessRichmediaRequest:request];
            }];
        }
    }
    
    if ([@"about" isEqualToString:scheme])
    {
        // Let UIWebView figure it out since it loads them often
        // for random acts of JavaScript, or so it seems.
        return YES;
    }
    
    //
    // TODO: For now allowing UIWebViewNavigationTypeOther since theres no way to know
    // how the navigation occured from the UIWebView.  This will allow iframes to be used
    // by an ad but may also allow an ad to randomly navigate the web view to some normal
    // web page (say http://www.mocean.com) which is NOT supported by the SDK.
    //
    //if ((navigationType == UIWebViewNavigationTypeLinkClicked) ||
    //    (navigationType == UIWebViewNavigationTypeOther))
    //
    // Need to revisit and attempt to trap usages in JS and attempt to determine their
    // source and then allow access to UIWebViewNavigationTypeOther when used by iframes.
    //
    
    // Normally canOpenInternall would be processed inside the navigation type selection.
    // However, it's being done outside becuase of the above handling of UIWebViewNavigationTypeOther.
    BOOL canOpenInternal = YES;
    if ([[request.URL.scheme lowercaseString] hasPrefix:@"http"] == NO)
    {
        canOpenInternal = NO;
    }
    
    NSString* host = [request.URL.host lowercaseString];
    if ([host hasSuffix:@"itunes.apple.com"] || [host hasSuffix:@"phobos.apple.com"])
    {
        // TODO: May need to follow all redirects to determine if it's an itunes link.
        // http://developer.apple.com/library/ios/#qa/qa1629/_index.html
        
        canOpenInternal = NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        __block BOOL shouldOpen = YES;
        if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldOpenURL:)])
        {
            [self invokeDelegateBlock:^
            {
                 shouldOpen = [self.delegate MASTAdView:self shouldOpenURL:request.URL];
            }];
        }
        
        if (shouldOpen == NO)
            return NO;
        
        if (canOpenInternal && self.useInternalBrowser)
        {
            [self openAdBrowserWithURL:request.URL];
            return NO;
        }
        
        [self invokeDelegateSelector:@selector(MASTAdViewWillLeaveApplication:)];
        
        self.skipNextUpdateTick = YES;
        
        [[UIApplication sharedApplication] openURL:request.URL];
        
        // Never let the ad's window render the destination link.
        return NO;
    }

    if ((navigationType == UIWebViewNavigationTypeOther) && (canOpenInternal == NO))
    {
        __block BOOL shouldOpen = YES;
        if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldOpenURL:)])
        {
            [self invokeDelegateBlock:^
             {
                 shouldOpen = [self.delegate MASTAdView:self shouldOpenURL:request.URL];
             }];
        }
        
        if (shouldOpen == NO)
            return NO;
        
        [self invokeDelegateSelector:@selector(MASTAdViewWillLeaveApplication:)];
        
        self.skipNextUpdateTick = YES;
        
        [[UIApplication sharedApplication] openURL:request.URL];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wv
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    @autoreleasepool
    {
        [wv disableSelection];
        
        [self mraidInitializeBridge:self.mraidBridge forWebView:wv];
    }
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [self resetWebAd];
    
    [self logEvent:[error description]
            ofType:MASTAdViewLogEventTypeError
              func:__func__
              line:__LINE__];
    
    if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
        }];
    }
}

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    if (self.connection != conn)
        return;
    
    self.connection = nil;
    
    [self logEvent:[error description]
            ofType:MASTAdViewLogEventTypeError
              func:__func__
              line:__LINE__];
    
    if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
    {
        [self invokeDelegateBlock:^
        {
            [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
        }];
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    if (conn != self.connection)
        return;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == NO)
    {
        // Not an HTTP response for whatever reason, kill it.
        [conn cancel];

        self.connection = nil;
        
        if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
        {
            NSError* error = [NSError errorWithDomain:@"Non-HTTP response from ad server."
                                                 code:0
                                             userInfo:nil];
            
            [self invokeDelegateBlock:^
            {
                [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
            }];
        }
        
        return;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    if ([httpResponse statusCode] != 200)
    {
        [conn cancel];
        self.connection = nil;
        
        if ([self.delegate respondsToSelector:@selector(MASTAdView:didFailToReceiveAdWithError:)])
        {
            NSError* error = [NSError errorWithDomain:@"Non-200 response from ad server."
                                                 code:0
                                             userInfo:nil];
            
            [self invokeDelegateBlock:^
            {
                [self.delegate MASTAdView:self didFailToReceiveAdWithError:error];
            }];
        }
        
        return;
    }
    
    self.dataBuffer = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    if (conn != self.connection)
        return;
    
    [self.dataBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    if (conn != self.connection)
        return;
    
    NSData* content = [[NSData alloc] initWithData:self.dataBuffer];
    
    [self loadContent:content];
    
    self.connection = nil;
    self.dataBuffer = nil;
}

#pragma mark - Logging

- (void)logEvent:(NSString*)event ofType:(MASTAdViewLogEventType)type func:(const char*)func line:(int)line
{
    if (type > self.logLevel)
        return;
    
    NSString* eventString = [NSString stringWithFormat:@"[%d, %s] %@", line, func, event];
    
    __block BOOL shouldLog = YES;
    if ([self.delegate respondsToSelector:@selector(MASTAdView:shouldLogEvent:ofType:)])
    {
        [self invokeDelegateBlock:^
         {
             shouldLog = [self.delegate MASTAdView:self shouldLogEvent:eventString ofType:type];
         }];
    }
    
    if (shouldLog == NO)
        return;
    
    NSString* typeString = @"Info";
    if (type == MASTAdViewLogEventTypeError)
        typeString = @"Error";
    
    NSString* logEvent = [NSString stringWithFormat:@"MASTAdView: %@\n\tType: %@\n\tEvent: %@",
                          self, typeString, eventString];
    
    NSLog(@"%@", logEvent);
}

#pragma mark - Location Services

- (void)setLocationDetectionEnabled:(BOOL)enabled
{
    if (!enabled)
    {
        [self.locationManager setDelegate:nil];
        [self.locationManager stopUpdatingLocation];
        
        if ([self.locationManager respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)])
            [self.locationManager stopMonitoringSignificantLocationChanges];
        
        self.locationManager = nil;
        locationDetectionEnabled = NO;
        
        [self.adRequestParameters removeObjectsForKeys:[NSArray arrayWithObjects:@"lat", @"long", nil]];
        
        return;
    }
    
    [self setLocationDetectionEnabledWithPupose:nil
                            significantUpdating:YES
                                 distanceFilter:1000
                                desiredAccuracy:kCLLocationAccuracyThreeKilometers];
}

- (void)setLocationDetectionEnabledWithPupose:(NSString*)purpose
                          significantUpdating:(BOOL)significantUpdating
                               distanceFilter:(CLLocationDistance)distanceFilter
                              desiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    BOOL available = YES;
    if ([CLLocationManager respondsToSelector:@selector(authorizationStatus)])
    {
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if ((authStatus != kCLAuthorizationStatusNotDetermined) && (authStatus != kCLAuthorizationStatusAuthorized))
        {
            available = NO;
        }
    }
    
    if (available && ([CLLocationManager locationServicesEnabled] == NO))
        available = NO;
    
    if (available == NO)
    {
        [self.locationManager setDelegate:nil];
        [self.locationManager stopUpdatingLocation];
        
        if ([self.locationManager respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)])
            [self.locationManager stopMonitoringSignificantLocationChanges];
        
        self.locationManager = nil;
        
        return;
    }
    
    [self.locationManager stopUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)])
        [self.locationManager stopMonitoringSignificantLocationChanges];
    
    if (self.locationManager == nil)
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    
    if ((locationDetectionEnabled == NO) && (purpose != nil))
        self.locationManager.purpose = purpose;
    
    self.locationManager.distanceFilter = distanceFilter;
    self.locationManager.desiredAccuracy = desiredAccuracy;
    
    if (significantUpdating && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [locationManager startMonitoringSignificantLocationChanges];
    }
    else
    {
        [locationManager startUpdatingLocation];
    }
    
    locationDetectionEnabled = YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.adRequestParameters removeObjectsForKeys:[NSArray arrayWithObjects:@"lat", @"long", nil]];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    if (newLocation == nil)
    {
        [self.adRequestParameters removeObjectsForKeys:[NSArray arrayWithObjects:@"lat", @"long", nil]];
        return;
    }
    
    NSString* lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    [self.adRequestParameters setValue:lat forKey:@"lat"];
    [self.adRequestParameters setValue:lon forKey:@"long"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{

}

#pragma mark - UI helpers

- (CGSize)screenSizeIncludingStatusBar:(BOOL)includeStatusBar
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect applicationBounds = [[UIScreen mainScreen] applicationFrame];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize screenSize = screenBounds.size;
    if (includeStatusBar)
        screenSize = applicationBounds.size;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        return screenSize;
    
    screenSize = CGSizeMake(screenSize.height, screenSize.width);
    return screenSize;
}

- (CGRect)absoluteFrameForView:(UIView*)view
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect windowRect = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    CGRect rectAbsolute = [view convertRect:view.bounds toView:nil];

    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        windowRect = MASTXYWidthHeightRectSwap(windowRect);
        rectAbsolute = MASTXYWidthHeightRectSwap(rectAbsolute);
    }
    
    rectAbsolute = MASTFixOriginRotation(rectAbsolute, interfaceOrientation,
                                         windowRect.size.width, windowRect.size.height);

    return rectAbsolute;
}

// Attribution: http://stackoverflow.com/questions/6034584/iphone-correct-landscape-window-coordinates
CGRect MASTXYWidthHeightRectSwap(CGRect rect)
{
    CGRect newRect = CGRectZero;
    newRect.origin.x = rect.origin.y;
    newRect.origin.y = rect.origin.x;
    newRect.size.width = rect.size.height;
    newRect.size.height = rect.size.width;
    return newRect;
}

// Attribution: http://stackoverflow.com/questions/6034584/iphone-correct-landscape-window-coordinates
CGRect MASTFixOriginRotation(CGRect rect, UIInterfaceOrientation orientation, int parentWidth, int parentHeight) 
{
    CGRect newRect = CGRectZero;
    switch(orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), rect.origin.y, rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            newRect = CGRectMake(rect.origin.x, parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
        case UIInterfaceOrientationPortrait:
            newRect = rect;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newRect = CGRectMake(parentWidth - (rect.size.width + rect.origin.x), parentHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
            break;
    }
    return newRect;
}

@end
