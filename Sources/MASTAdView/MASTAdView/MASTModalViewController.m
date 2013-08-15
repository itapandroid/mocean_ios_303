//
//  MASTModalViewController.m
//  MASTAdView
//
//  Created on 1/2/13.
//  Copyright (c) 2013 Mocean Mobile. All rights reserved.
//

#import "MASTModalViewController.h"

@interface MASTModalViewController ()

@property (nonatomic, assign) UIInterfaceOrientation forcedOrientation;

@end

@implementation MASTModalViewController

@synthesize delegate, allowRotation;
@synthesize forcedOrientation;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.allowRotation = YES;
        self.forcedOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.allowRotation)
        return YES;
    
    if (toInterfaceOrientation == self.forcedOrientation)
        return YES;
    
    return NO;
}

- (BOOL)shouldAutorotate
{
    if (self.allowRotation)
        return YES;
    
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.allowRotation)
        return [[UIApplication sharedApplication] statusBarOrientation];
    
    return self.forcedOrientation;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.allowRotation)
        return UIInterfaceOrientationMaskAll;
    
    switch (self.forcedOrientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortrait;

        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscape;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(MASTModalViewControllerDidRotate:)])
    {
        [self.delegate MASTModalViewControllerDidRotate:self];
    }
}

- (void)forceRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.forcedOrientation = interfaceOrientation;
    
    UIViewController* presentingController = self.parentViewController;
    
    if ([self respondsToSelector:@selector(presentingViewController)])
    {
        presentingController = [self presentingViewController];
    }
    
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:NO completion:^
        {
            [presentingController presentModalViewController:self animated:NO];
        }];
    }
    else
    {
        [self dismissModalViewControllerAnimated:NO];
        [presentingController presentModalViewController:self animated:NO];
    }
}

@end
