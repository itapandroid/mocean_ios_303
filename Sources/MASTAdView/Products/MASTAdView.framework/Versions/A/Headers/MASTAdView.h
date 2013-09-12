//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.
//
//
//
// This is the only header required for integrating into projects that will use the MASTAdView SDK.
//
//

/// *Required Frameworks*
///
/// These must be added to projects (via project's link build phase) that use the MASTAdView SDK.
///
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>



// This header is provided for support and debugging of locally generated ads.
#import "MASTMoceanAdDescriptor.h"


@class MASTAdView;


/** Ad placement type.
 */
typedef enum
{
    /// Ad is placed in application content.
    MASTAdViewPlacementTypeInline = 0, 
    
    /// Ad is placed over and in the way of application content.
    /// Generally used to place an ad between transtions in an application
    /// and consumes the entire screen.
    MASTAdViewPlacementTypeInterstitial
    
} MASTAdViewPlacementType;


/** Event log types.
 */
typedef enum
{
    MASTADViewLogEventTypeNone = 0,
    MASTAdViewLogEventTypeError = 1,
    MASTAdViewLogEventTypeDebug = 2,
} MASTAdViewLogEventType;


/** Protocal for interaction with the MASTAdView.
 
 The entire protocol is optional.  Some messages override default behavior and some are required
 to get full support for MRAID 2 ad content (saving calendar entries or pictures).
 
 All messages are guaranteed to occur on the main thread.  If any long running tasks are needed
 in reponse to any of the sent messages then they should be executed in a background thread to
 prevent and UI delays for the user.
 */
@protocol MASTAdViewDelegate <NSObject>
@optional

/** Sent after an ad has been downloaded and rendered.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewDidRecieveAd:(MASTAdView*)adView;


/** Sent if an error was encoutered while donloading or rendering an ad.
 
 @param adView The MASTAdView instance sending the message.
 @param error The error encountered while attempting to receive or render the ad.
 */
- (void)MASTAdView:(MASTAdView*)adView didFailToReceiveAdWithError:(NSError*)error;


/** Sent when the ad will navigate to a clicked link.
 
 Not implementing this method behaves as if `YES` was returned.
 
 @param adView The MASTAdView instance sending the message.
 @param url The URL to open.
 @return `YES` Allow the SDK to open the link with UIApplication's openURL: or the internal browser.
 @return `NO` Ignore the request
 */
- (BOOL)MASTAdView:(MASTAdView*)adView shouldOpenURL:(NSURL*)url;


/** Sent when the close button is pressed by the user.
 
 This only occurs for the close button enabled with setCloseButton:afterDelay: or in the case of a
 interstitial richmedia ad that closes itself.  It will not be sent for richmedia close buttons that 
 collapse expanded or resized ads.
 
 The common use case is for interstitial ads so the developer will know when to call closeInterstitial.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewCloseButtonPressed:(MASTAdView*)adView;


/** Implement to return a custom close button.  
 
 This button will be used for richmedia ads if the richmedia ad does not indicate it has its own
 custom close button.  It is also used if showCloseButton:afterDelay: enables the close button.

 @warning Do not return the same UIButton instance to different adView instances.
 
 @warning Developers should take care of adding action handlers to the button as it will 
 be reused and may persist beyond the handlers lifetime.
 
 @param adView The MASTAdView instance sending the message.
 @return UIButton instance.
 */
- (UIButton*)MASTAdViewCustomCloseButton:(MASTAdView*)adView;


/** Sent before the ad content is expanded in response to a richmedia expand event.
 
 The ad view itself is not expanded, instead a new window is displayed with the
 expanded ad content.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewWillExpand:(MASTAdView*)adView;


/** Sent after the ad content is expanded in response to a richmedia expand event.
 
 The ad view itself is not expanded, instead a new window is displayed with the
 expanded ad content.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewDidExpand:(MASTAdView*)adView;


/** Sent before the ad content is resized in response to a richmedia resize event.
 
 The ad view itself is not resized, instead a new window is displayed with the
 resized ad content.
 
  @param adView The MASTAdView instance sending the message.
  @param frame The frame relative to the window where the resized content is displayed.
 */
- (void)MASTAdView:(MASTAdView *)adView willResizeToFrame:(CGRect)frame;


/** Sent after the ad content is resized in response to a richmedia resize event.
 
 The ad view itself is not resized, instead a new window is displayed with the
 resized ad content.
 
 @param adView The MASTAdView instance sending the message.
 @param frame The frame relative to the window where the resized content is displayed.
 */
- (void)MASTAdView:(MASTAdView *)adView didResizeToFrame:(CGRect)frame;


/** Sent before ad content is collaped if expanded or resized.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewWillCollapse:(MASTAdView*)adView;


/** Sent after ad content is collaped if expanded or resized.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewDidCollapse:(MASTAdView*)adView;


/** Sent before the internal browser is opened.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewInternalBrowserWillOpen:(MASTAdView*)adView;


/** Sent after the internal browser is opened.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewInternalBrowserDidOpen:(MASTAdView*)adView;


/** Sent before the internal browser is closed.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewInternalBrowserWillClose:(MASTAdView*)adView;


/** Sent after the internal browser is closed.
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewInternalBrowserDidClose:(MASTAdView*)adView;


/** Sent before the ad opens a URL that invokes another application (ex: Safari or App Store).
 
 @param adView The MASTAdView instance sending the message.
 */
- (void)MASTAdViewWillLeaveApplication:(MASTAdView*)adView;


/** Sent when the ad view is about to log an event.
 
 Logging in the SDK is done with NSLog().  Implement and return `NO` to log to application specific
 log files.  This message will only be sent if the event type is equal to or higher than the MASTADView
 instance logLevel property.
 
 @param adView The MASTAdView instance sending the message.
 @param event The log event to log.
 @param type The event type.
 @return `YES` Log the event to NSLog().
 @return `NO` Omit logging the event to NSLog().
 */
- (BOOL)MASTAdView:(MASTAdView*)adView shouldLogEvent:(NSString*)event ofType:(MASTAdViewLogEventType)type;


/** Sent to allow developers to override SMS support.
 
 If the device supports SMS this message will be sent to allow the developer to override support.
 The default behavior is to allow SMS usage.
 
 This message is not sent of the device does not support SMS.
 
 @param adView The MASTAdView instance sending the message.
 @return `NO` Informs richmedia ads that SMS is not supported.
 @return `YES` Informs richmedia ads that SMS is supported.
 */
- (BOOL)MASTAdViewSupportsSMS:(MASTAdView*)adView;


/** Sent to allow developers to override phone support.
 
 If the device supports phone dialling this message will be sent to allow the developer to override support.
 The default behavior is to allow phone dialing.
 
 This message is not sent of the device does not support phone dialing.
 
 @param adView The MASTAdView instance sending the message.
 @return `NO` Informs richmedia ads that phone calls is not supported.
 @return `YES` Informs richmedia ads that phone calls is supported.
 */
- (BOOL)MASTAdViewSupportsPhone:(MASTAdView*)adView;


/** Sent to allow developers to override calendar support.
 
 Implement to indicate if calendar events can be created.
 The default behavior is to NOT allow calendar access.
 
 On iOS 6 and later user permission is required to access the calendar.  If this message is 
 implemented and returns YES then the SDK will ask the user for permission during [MASTAdView update]
 or [MASTAdView updateWithTimeInterval:]. Refer to iOS EKEventStore documentation for more information.
 
 @see [MASTAdViewDelegate MASTAdView:shouldSaveCalendarEvent:inEventStore:]
 
 @param adView The MASTAdView instance sending the message.
 @return `NO` Informs richmedia ads that calendar access is not supported.
 @return `YES` Informs richmedia ads that calendar access is supported.
 */
- (BOOL)MASTAdViewSupportsCalendar:(MASTAdView*)adView;


/** Sent to allow developers to override picture storing support.
 
 Implement to indicate if storing pictures is supported. The default behavior is to NOT allow storing
 of pictures.
 
 @see [MASTAdViewDelegate MASTAdView:shouldSavePhotoToCameraRoll:]
 
 @param adView The MASTAdView instance sending the message.
 @return `NO` Informs richmedia ads that storing pictures is not supported.
 @return `YES` Informs richmedia ads that storing pictures is supported.
 */
- (BOOL)MASTAdViewSupportsStorePicture:(MASTAdView*)adView;


/** Sent when the ad server receives a third party ad request from the ad network.
 
 This can be implemented to invoke a third party ad SDK to render the requested content.  The adView 
 does no further processing of the third party request.
 
 @param adView The MASTAdView instance sending the message.
 @param properties Properties of the request.
 @param params Params for the third party SDK.
 */
- (void)MASTAdView:(MASTAdView*)adView didReceiveThirdPartyRequest:(NSDictionary*)properties withParams:(NSDictionary*)params;


/** Sent when an ad desires to play a video in an external player.
 
 The default is to open the URL and play the video.
 
 Developers can use an application player and return NO to play the video directly.
 
 @param adView The MASTAdView instance sending the message.
 @param videoURL The URL string of the video to play.
 @return `NO` Do not open the URL and play the video.
 @return `YES` Invoke UIApplication openURL: to play the video.
 */
- (BOOL)MASTAdView:(MASTAdView*)adView shouldPlayVideo:(NSString*)videoURL;


/** Sent when a richmedia ad attempts to create a new calendar entry.
 
 Application developers can implement the dialog directly if desired by capturing the event
 and eventStore and returning `nil`.  If not implemented the SDK will ignore the request.
 
 @param adView The MASTAdView instance sending the message.
 @param event The event to save.
 @param eventStore the store to save the event too.
 @return `NO` Do not attempt to add the calendar event.
 @return `YES` Present the calendar event editor to the user to allow them to edit and save or cancel the event.
 */
- (BOOL)MASTAdView:(MASTAdView*)adView shouldSaveCalendarEvent:(EKEvent*)event inEventStore:(EKEventStore*)eventStore;


/** Sent when a richmedia ad attempts to save a picture to the camera roll.
 
 Application developers should implement this by prompting the user to save the image and then saving
 it directly and returning NO from this delegate method.  If not implemented the image will NOT be
 saved to the camera roll.
 
 Note: iOS 6 added privacy options for applications saving to the camera roll.  The user will be
 prompted by iOS on the first attempt at accessing the camera roll.  If the user selects No then
 pictures will not be saved to the camera roll even if this method is implemented and returns `YES`.
 
 @param adView The MASTAdView instance sending the message.
 @param image The image to save.
 @return `NO` Do not save the image to the camera roll.
 @return `YES` Attempt to save the image to the camera roll.
 */
- (BOOL)MASTAdView:(MASTAdView*)adView shouldSavePhotoToCameraRoll:(UIImage*)image;


/** Sent after the SDK process a richmedia event.
 
 Applications can use this to react to various events if necessary but the SDK will have
 already processed them as necessary (expanded in result of an expand request).
 
 @warning Developers should not attempt to implement the specified event.  The SDK will
 have already processed the event with the SDK implementation.
 
 See the IAB MRAID 2 specification on the event types.
 
 @param adView The MASTAdView instance sending the message.
 @param event The NSURLRequest containing the event request.
 */
- (void)MASTAdView:(MASTAdView *)adView didProcessRichmediaRequest:(NSURLRequest*)event;


/** Sent to allow the application to override the controller used to present modal controllers.
 
 The SDK by default will use the application's rootViewController property to display modal dialogs.
 These include richmedia expand, internal browser and calendar event creation.  To override using
 this controller implement this message and return the view controller that can be used to present
 modal view controllers.
 
 Note: Application's SHOULD have a rootViewController set but the iOS SDK will allow an application
 to run without one.  If the application can not set up the rootViewController as expected then this
 method MUST be implemented to return a view controller that can be used to present modal dialogs.
 Without one certain SDK features will not work including showInterstitial, richmedia expand and
 the internal browser.
 
 @param adView The MASTAdView instance sending the message.
 @return UIViewController to use as the presenting view controller for any SDK modal view controller.
 */
- (UIViewController*)MASTAdViewPresentationController:(MASTAdView*)adView;


/** Sent to allow the application to override the superview used for ad resizing and visibility.
 
 The supplied view MUST be a superview in the hierarchy to the MASTAdView instance.
 
 The SDK by default will attempt to find a suitable default using the MASTAdView instance's window's
 rootViewController view, the application's keyWindow rootViewController's view and finally the
 MASTAdView's superview.
 
 Note: Application's SHOULD have a rootViewController set for the application window but the iOS SDK
 will allow an application to run without one.  If the application can not set up the rootViewController
 as expected then this method MUST be implemented to return a view controller that can be used for 
 resizing.  Without one set the resize feature may not work correctly.
 
 @param adView The MASTAdView instance sending the message.
 @return UIView to use as the superview when placing the resize view container.
 */
- (UIView*)MASTAdViewResizeSuperview:(MASTAdView*)adView;


@end


/** Renders text, image and richmedia ads.
 
 TODO: Include more information here and possibly a quick sample.
 
 The -ObjC linker option is required when including the MASTAdView SDK.
 
 */
@interface MASTAdView : UIView


 /** Returns the MASTAdView SDK's version.
 */
+ (NSString*)version;


/** Unregisters the protocol class used to intercept the MRAID bridge request
 from rich media ads.
 
 Note: The registered NSURLProtocol class used by the SDK only intercepts requests
 for "mraid.js" from a UIWebView.
 
 @see [NSURLProtocol](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLProtocol_Class/Reference/Reference.html) for any possible impact to the application.
 */
+ (void)unregisterProtocolClass;


///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/** Initilizes an inline instance of the ad view.
 
 The view can be added to other views as with any other UIView object.  The frame is
 used to determine the size of the ad in the requested to the ad server.  If not known
 at initialization time, ensure that the view's frame is set prior to calling update.
 
 @param frame The area to place the view.
 */
- (id)initWithFrame:(CGRect)frame;


/** Initializes an interstital instance of the ad view.
 
 The view is NOT intended to be used inline with other content or added to
 other views.  Instead use the interstitial methods to show and close the
 full screen view.
 
 @see showInterstitial
 @see showInterstitialWithDuration:
 @see closeInterstitial
 */
- (id)initInterstitial;


/** Returns the placement type for the instance.
 
 This is set based on how the instance was initialized.
 
 @see initWithFrame:
 @see initInterstitial
 */
@property (nonatomic, readonly) MASTAdViewPlacementType placementType;


///---------------------------------------------------------------------------------------
/// @name Required configuration
///---------------------------------------------------------------------------------------

/** Specifies the zone for the ad network.
 */
@property (nonatomic, assign) NSInteger zone;


///---------------------------------------------------------------------------------------
/// @name Optional configuration
///---------------------------------------------------------------------------------------

// Set the server and additional parameters as required.
// These are only needed for advanced usages.

/** Specifies the URL of the ad server.
 */
@property (nonatomic, copy) NSString* adServerURL;


/** Allows setting extra server parameters.
 
 The SDK will set various parameters based on configuration and other options.
 
 For more information see http://developer.moceanmobile.com/Mocean_Ad_Request_API.
 
 @warning All parameter key and values must be NSString instances.
 */
@property (nonatomic, readonly) NSMutableDictionary* adRequestParameters;


/** Set to enable the use of the internal browser for opening ad content.  Defaults to `NO`.
 
 @see isInternalBrowserOpen
 @see [MASTAdViewDelegate MASTAdViewInternalBrowserWillOpen:]
 @see [MASTAdViewDelegate MASTAdViewInternalBrowserDidOpen:]
 @see [MASTAdViewDelegate MASTAdViewInternalBrowserWillClose:]
 @see [MASTAdViewDelegate MASTAdViewInternalBrowserDidClose:]
 */
@property (nonatomic, assign) BOOL useInternalBrowser;


/** Returns the status of the internal browser.
 
 @see useInternalBrowser
 */
@property (nonatomic, readonly) BOOL isInternalBrowserOpen;


/** Sets the MASTAdViewDelegate delegate receiever for the ad view.
 
 @warning Proper reference management practices should be observed when using delegates.
 @warning Ensure that the delegate is set to nil prior to releasing the ad view's instance.
 */
@property (nonatomic, assign) id<MASTAdViewDelegate> delegate;


///---------------------------------------------------------------------------------------
/// @name Updating and resetting ad content
///---------------------------------------------------------------------------------------

/** Issues an update request.  The request is deferred until user action is completed.
 
 @see update:
 */
- (void)update;


/** Issues an update.
 
 Resets any interval update from updateWithTimeInterval:.
 
 The update will be deferred if the user is interacting with the ad instance.  This can 
 include the internal browser being open or a rich media ad in an expanded or resized state.
 If deferred the update will resume when the interaction is completed.  Specifying YES to
 the force property will close any user interaction and perform the update immediately.
 
 If [MASTAdViewDelegate MASTAdViewSupportsCalendar:] is implemented by the delegate then
 this message will determine if a request to the user for access to the calendar is needed.
 If so, the instance will request access from the user.  Developers desiring to control when
 this request occurs can do so prior to calling update.  Refer to iOS EKEventStore
 documentation for more information.

 @param force Set to `YES` to force an update regardless of current ad status/interaction.
 */
- (void)update:(BOOL)force;


/** Issues an update request that will be deferred if the ad is currently being interacted with.
 Will automatically update every interval seconds (can vary depending on user interaction).
 
 If [MASTAdViewDelegate MASTAdViewSupportsCalendar:] is implemented by the delegate then
 this message will determine if a request to the user for access to the calendar is needed.
 If so, the instance will request access from the user.  Developers desiring to control when
 this request occurs can do so prior to calling update.  Refer to iOS EKEventStore
 documentation for more information.
 
 @warning Ensure [MASTAdView reset] is invoked when the instance will no longer be used or
 is being removed from the view stack.  This will prevent the main NSRunLoop from retaining
 the MASTAdView instance after its intended release.
 
 @see reset
 
 @param interval The delay between requesting updates after the initial update.
 */
- (void)updateWithTimeInterval:(NSTimeInterval)interval;


/** Restates the instance to its default state.
 
 -Stops updates and cancels the update interval.
 -Stops location detection.
 -Collapses any expanded or resized richmedia ads.
 -Closes interstitial.
 -Closes internal ad browser.
 
 Should be sent before releasing the instance if another object may be retaining it 
 such as a superview or list.  This allows the application to suspend ad updating 
 and interaction activities to allow other application activitis to occur.  After
 responding to other activities update or updateWithTimeInterval: can be sent again
 to resume ad updates.
 
 @warning If the project is using ARC (automatic reference counting) this MUST be called
 to cancel internal timers.  If not the main NSRunLoop will retain a reference to the 
 MASTAdView instance and continue invoking its timers.
 @warning Does not reset the delegate.
 */
- (void)reset;


/** Removes any displayed ad content and any associated state.
 
 -Collapses any expanded or resized richmedia ads.
 -Closes interstitial.
 
 Cancels any deferred update.
 
 Unlike reset, it does not reset the instance to it's default state.
 
 @see update:
 */
- (void)removeContent;


///---------------------------------------------------------------------------------------
/// @name Controlling interstitial presentation
///---------------------------------------------------------------------------------------

/** Shows and closes the interstitial view.

 Can only be used if the instance was initialized with initInterstitial.
 */
- (void)showInterstitial;


/** Shows the interstitial and automatically closes after the specified duration.
 
 Can only be used if the instance was initialized with initInterstitial.
 
 @param duration The amount of time to display the interstitial before closing it.
 */
- (void)showInterstitialWithDuration:(NSTimeInterval)duration;


/** Closes the interstitial.
 
 */
- (void)closeInterstitial;


///---------------------------------------------------------------------------------------
/// @name Close button support
///---------------------------------------------------------------------------------------

/** Shows a close button after the specified delay after the ad is rendered.
 
 This can be used for both inline/banner/custom and interstitial ads.  For most cases
 this should not be required since banner ads don't usually have a need for a close 
 button and richmedia ads that expand or resize will offer their own close button.
 
 This SHOULD be used for interstitial ads that are known to not be richmedia as they
 will not have a built in close button.
 
 The setting applies for all subsequent updates.  The button can be customized using the 
 MASTAdViewCustomCloseButton: delegate method.
 
 @warning Ensure [MASTAdView reset] is invoked when the instance will no longer be used or
 is being removed from the view stack.  This will prevent the main NSRunLoop from retaining 
 the MASTAdView instance after its intended release.
 
 @see reset
 
 @param showCloseButton Set to `YES` to display the close button after rendering ads.
 @param delay The time to delay showing the close button after rendering the ad.  A
 value of 0 will show the button immediately.
 */
- (void)showCloseButton:(BOOL)showCloseButton afterDelay:(NSTimeInterval)delay;


///---------------------------------------------------------------------------------------
/// @name Location detection support
///---------------------------------------------------------------------------------------

/** Returns the enablement status of location detection.
 
 May return `NO` even if one of the setLocationDetectionEnabled methods was used
 to enable it.  This can happen if the device doesn't support location enablement
 or if the user has denied location permissions to the application.  Note however
 that this property should not be used to determine either of those cases for the
 application.
 */
@property (nonatomic, readonly) BOOL locationDetectionEnabled;


/** Used to enable or disable location detection.
 
 Enabling location detection makes use of the devices location services to 
 set the lat and long server properties that get sent with each ad request.
 
 Note that it could take time to acquire the location so an immediate update
 call after location detection enablement may not include the location in the
 ad network request.
 
 A call to reset will stop location detection.
 
 When enabling location detection with this method the most power efficient 
 options are used based on the devices capabilities.  To specify more control
 over location options enable with setLocationDetectionEnabledWithPurpose:...
 
 @param enabled `YES` to enable location detection with defaults, `NO` to disable location detection.
 */
- (void)setLocationDetectionEnabled:(BOOL)enabled;


/** Used to enable location detection with control over how the location is acquired.

 @see [CLLocationManager](http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLLocationManager_Class/CLLocationManager/CLLocationManager.html) for reference on the purpose, distanceFilter and desiredAccuracy parameters.
 
 @warning It is possible to configure location detection to use significant power and reduce
 battery life of the device.  For most applications where location detection is desired use 
 setLocationDetectionEnabled: for optimal battery life based on the device's capabilities.
 
 @param purpose Message to present to the user as to why location is being used.  Can be nil.
 @param significantUpdating If set to `YES` uses the startMonitoringSignificantLocationChanges
 if available on the device.  If not available then this parameter is ignored.  When available
 and set to `YES` this parameter causes the distanceFilter and desiredAccuracy parameters to
 be ignored.  If set to `NO` then startUpdatingLocation is used and the distanceFilter and
 desiredAccuracy parameters are applied.
 @param distanceFilter Amount of distance used to trigger updates.
 @param desiredAccuracy Acuracy needed for updates.
 */
- (void)setLocationDetectionEnabledWithPupose:(NSString*)purpose
                          significantUpdating:(BOOL)significantUpdating
                               distanceFilter:(CLLocationDistance)distanceFilter
                              desiredAccuracy:(CLLocationAccuracy)desiredAccuracy;


///---------------------------------------------------------------------------------------
/// @name Ad containers
///---------------------------------------------------------------------------------------

// These are available to customize text and image ad appearance
// if desired.  Do not change properties that would affect placement
// or behavior in their superview (the ad view).

/** Text ad container.
 
 This can be accessed to modify how text is rendered such as font size, color, background color, etc...
 
 @warning Do not attempt to move or affect the relationship of the view within its superview.
 */
@property (nonatomic, readonly) UILabel* labelView;

/** Image ad container.
 
 This can be accessed to modify how the image is handled.
 
 @warning Do not attempt to move or affect the relationship of the view within its superview.
 */
@property (nonatomic, readonly) UIImageView* imageView;

/** Web view ad container.
 
 This can be modified to change aspects of the web view such as background color, etc..
 
 @warning Do not attempt to move or affect the relationship of the view within its superview.
 @warning Do not attempt to change the delegate or affect how content is rendered as this may
 interfere with richmedia ads.
 */
@property (nonatomic, strong) UIWebView* webView;

/** Richmedia expand view container.
 
 This view is the container used to hold the view to be expanded.  For richmedia ads that request
 an expand this will contain the UIWebView.  This doesn't include richmedia ads that expand with
 another creative (two part expand).
 
 @warning Do not attempt to move or affect the relationship of the view within its superview.
 */
@property (nonatomic, readonly) UIView* expandView;

/** Richmedia resize view container.
 
 This view is the container used to render resized richmedia ad it requests to resize.
 
 @warning Do not attempt to move or affect the relationship of the view within its superview.
 */
@property (nonatomic, readonly) UIView* resizeView;


///---------------------------------------------------------------------------------------
/// @name Test content, logging and debugging
///---------------------------------------------------------------------------------------


/** Instructs the ad server to return test ads for the configured zone.
 
 @warning This should never be set to `YES` for application releases.
 */
@property (nonatomic, assign) BOOL test;


/** Specifies the log level.  All logging is via NSLog().
 
 @see [MASTAdViewDelegate MASTAdView:shouldLogEvent:ofType:]
 */
@property (nonatomic, assign) MASTAdViewLogEventType logLevel;


/** Renders an ad directly without downloading it from the ad network.
 
 An update in progress due to update or updateWithTimeInterval: will override any
 ad set with this method.  Call reset prior to calling this if update was used
 to download an ad from the ad network.
 
 @warning This not intended to be used in application releases.
 
 @param adDescriptor The ad descriptor to render.
 */
- (void)renderWithAdDescriptor:(MASTMoceanAdDescriptor*)adDescriptor;


@end
