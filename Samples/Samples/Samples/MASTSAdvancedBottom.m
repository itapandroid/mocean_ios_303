//
//  MASTSAdvancedBottom.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSAdvancedBottom.h"

@interface MASTSAdvancedBottom ()

@end

@implementation MASTSAdvancedBottom

- (void)loadView
{
    [super loadView];

    CGRect frame = super.adView.frame;
    frame.size.width = CGRectGetWidth(super.view.bounds);
    frame.origin.y = CGRectGetMaxY(super.view.bounds) - frame.size.height;
    super.adView.frame = frame;
    
    // Update the autoresizing mask to include adjusting the top margin to cover 
    // the navigation bar and rotation and remove the width resizing and add the
    // left margine to center it.
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 88269;
    
    super.adView.zone = zone;
    
    super.adView.backgroundColor = [UIColor clearColor];
}

@end
