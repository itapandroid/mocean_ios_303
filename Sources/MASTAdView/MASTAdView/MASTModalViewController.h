//
//  MASTModalViewController.h
//  MASTAdView
//
//  Created on 1/2/13.
//  Copyright (c) 2013 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTModalViewController;

@protocol MASTModalViewControllerDelegate <NSObject>

- (void)MASTModalViewControllerDidRotate:(MASTModalViewController*)modalViewController;

@end

@interface MASTModalViewController : UIViewController

@property (nonatomic, assign) id<MASTModalViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL allowRotation;

- (void)forceRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
