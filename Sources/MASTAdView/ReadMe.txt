MASTAdView SDK 3.0
Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.

SDK Information:
http://developer.moceanmobile.com/SDKs

Project Source:
http://code.google.com/p/mocean-sdk-ios/


Release Notes:

3.0.1
- Corrected setting the various sizes to the MRAID bridge on rotation
- Corrected logLevel setting
- Added removeContent message to MASTAdView to allow resetting of ad content without resetting update timers
- Updated MRAID create calendar event logic to flow properly with modal presentation while expanded
- Added mcc and mnc parameters if obtainable via CoreTelephony (and now requires that framework)
- Exposed the UIWebView container to the MASTAdView public interface
- Properly invoke didFailToReceiveAd when a zone has no errors (and updated the logging for it)
- Added delegate message to allow custom modal presentation controller for MASTAdView modal controllers
- Changed calendar create event delegate message to return a BOOL vs. a UIViewController, the controller can now be returned in the new delegate mentioned above.
- Updated size of the SDK close button to increase hit area

3.0.2
- Updated project settings for Xcode 4.6.
- Corrected log type for 404 ad descriptor.
- Corrected MRAID feature name for tel (was phone).
- Hard coded isModal to true in MRAID controller and removed from native code.
- Corrected MRAID controller to fire resize event when state changes to resize even if already in the resize state.
- Removed MRAID bridge resize parameters for height and width (not specified in MRAID 2).  No change in behavior for MRAID 1 or MRAID 2 ads.
- Added compiler warning suppression to MASTDefaults.
- Track the close button timer so it can be properly invalidated as needed.
- Refactored logic used to report to the MRAID bridge various size and position data as well as the isViewable flag.
- Added code to verify the rootViewController is available before hiding the status bar when presenting a modal controller.  A rootViewController MUST be provided either by the keyWindow or though the MASTAdViewDelegate.
- Removed auto resizing flags from the resize view.  It is the responsibility of the MRAID ad to detect new sizing and issue a new resize with new resizeProperties as necessary.
- Properly invoke MRAID state change on the controller after a two part expand so the inline ad knows the two part has expanded.
- Properly close a two part expand when the inline ad invokes close.
- Corrected resize offset adjustment for the Y coordinate when enforcing allowOffscreen = false constraints in MRAID resize.
- Corrected status bar height adjustment for resize close control when device is landscape.
- Added missing MRAID top-center and bottom-center custom close position options for resizeProperties.
- Added invoke of didFailToReceiveAdWithError when an ad descriptor has no content and content is expected.
- Minor log entry formatting updates for entries that have extra detail.
- Corrected internal browser view layout so tool bar does not cover the web view.
- If the internal web browser detects it will leave the application it will automatically close.
- The resize container is now the rootViewController view.  The rootViewController is determined from the UIApplication UIWindow or from the MASTAdViewDelegate.
- The maxSize is now based on size of the rootViewController view and is affected by the status bar.
- Updated MRAID resize to account for a minium size that of the close control view, a maximum size that is less than the maxSize and that the close control area is on screen.  If these constraints are not met then the resize request will fail.
- Updated documentation for updateWithTimeInterval: and showCloseButton:afterDelay indicating reset must be called if the MASTAdView instance is being destroyed/deallocated.
- Added removeFromSuperview implementation to detect and invalidate update and close button timers and log (as errors) caution output that reset must be called if the MASTAdView instance is being destroyed/deallocated.
- Corrected default handling of interstitial to properly allow landscape interstitial presentation.
- Corrected showInterstitialWithDuration: timer creation.
- Reworked orientation properties parsing to default to allowing rotation vs. locking rotation if there is a parse issue with the properties.

3.0.3
- Updated default injection wrapper to use 0 vs. "no" for disabling user-scaling in the default viewport.
- Updated container autoresizeMask flags to better usages with the desired effect.
- Blocking/ignoring tap gesture for web view based ads as the UIWebView should consume them directly.

3.0.4
- Corrected tap handling for interstitial image and text ads.
- Reordered layout/sizing logic for MRAID to occur after SDK completes the close handling logic.
- Corrected HTTP/S check when determining what to allow the banner UIWebView to handle directly.
- Added MASTAdViewResizeSuperview: delegate message to allow developers to specify the base view in the view stack for MRAID resize operations.
- Reworked MRAID resize logic to account for proper max size between a full screen resize superview and a partial one.
- Added internal browser status property and delegate messages to allow notification when the internal browser is opened and closed.
- Removed now not-required site property.  The zone is all that is needed for obtaining ad content.  If used for other reason can be set with other optional parameters through adRequestParameters.
- The update message will now defer updates if the user is currently interacting with an ad via the internal browser or MRAID expand/resize.  An overloaded update: has been added to allow developers to force an update even if the user is interacting with the ad.
- The update message no longer stops the interstitial duration timer set with showInterstitialForDuration:.
- Fixed Generated Source build phase to support SDK compiling when placed in a path with spaces.
- Updated how the MRAID JavaScript bridge is injected into the UIWebView.  The new method allows the UIWebView to load it directly using a custom NSURLProtocol class.  This class is registered automatically and if needed can be unregistered with unregisterProtocolClass.
- Updated the logic to determine the controller to use for presenting modal controllers.  The first will be the instance's window's rootViewController followed by the application's first window's rootViewController, then they keyWindow's rootViewController.  The protocol MASTAdViewPresentationController: message can still override this behavior if necessary.
- Added a check and logic to handle cases where the internal browser may need to immediately close if the supplied URL redirects to a URL that isn't handled by the internal browser.
- Updated the internal browser to only redirect iTunes URLs to UIApplication's openURL: message.
- Added workaround for iOS5 to assist a previous change dealing with the internal browser immediately closing.

3.1.0
- Adding MRAID bridge init event for the SDK so that the bridge is initialized at the correct time.
- Adding logic to init the bridge after init is invoked and the web view is loaded.  This prevents init from occurring while the web view is still loading.
- Updated close button logic for rich media interstitials.


