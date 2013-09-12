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
