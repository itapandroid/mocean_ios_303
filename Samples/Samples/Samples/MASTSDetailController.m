//
//  MASTSDetailController.m
//  MASTSamples
//
//  Created on 4/16/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSDetailController.h"

@interface MASTSDetailController ()
@property (nonatomic, retain) UINavigationController* navController;
@end

@implementation MASTSDetailController

@synthesize viewController;
@synthesize navController;

- (void)dealloc
{
    self.viewController = nil;
    self.navController = nil;
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizesSubviews = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)setViewController:(UIViewController *)vc
{
    if (viewController != vc)
    {
        [viewController release];
        viewController = [vc retain];
    }
    
    UINavigationController* nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    nc.view.frame = self.view.bounds;
    
    [self.view addSubview:nc.view];
    
    [self.navController.view removeFromSuperview];
    self.navController = nc;
}

@end
