//
//  MASTSAppDelegate.h
//  AdMobileSamples
//
//  Created on 4/15/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MASTSMenuController.h"


@interface MASTSAppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate, MASTSMenuDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@end
