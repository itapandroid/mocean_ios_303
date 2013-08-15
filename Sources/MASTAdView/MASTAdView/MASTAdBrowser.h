//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTAdBrowser;

@protocol MASTAdBrowserDelegate <NSObject>
@required

- (void)MASTAdBrowser:(MASTAdBrowser*)browser didFailLoadWithError:(NSError*)error;

- (void)MASTAdBrowserClose:(MASTAdBrowser*)browser;

- (void)MASTAdBrowserWillLeaveApplication:(MASTAdBrowser*)browser;

@end

@interface MASTAdBrowser : UIViewController

@property (nonatomic, assign) id<MASTAdBrowserDelegate> delegate;

@property (nonatomic, copy) NSURL* URL;

@end
