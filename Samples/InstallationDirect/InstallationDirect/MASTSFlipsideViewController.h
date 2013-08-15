//
//  MASTSFlipsideViewController.h
//  InstallationDirect
//
//  Created on 10/11/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTSFlipsideViewController;

@protocol MASTSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(MASTSFlipsideViewController *)controller;
@end

@interface MASTSFlipsideViewController : UIViewController

@property (assign, nonatomic) id <MASTSFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
