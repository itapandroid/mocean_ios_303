//
//  MASTSMainViewController.h
//  InstallationDirect
//
//  Created on 10/11/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import "MASTSFlipsideViewController.h"

@interface MASTSMainViewController : UIViewController <MASTSFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
