//
//  MASTSViewController.m
//  InstallationFramework
//
//  Created on 10/11/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import "MASTSViewController.h"

// Import comes from the framework
#import <MASTAdView/MASTAdView.h>

@interface MASTSViewController ()

// Reference to the ad view (strong to keep it around if nothing else has references)
@property (nonatomic, strong) MASTAdView* adView;

// Using this to track when the ad view should update
@property (nonatomic, assign) BOOL updateAdView;

@end

@implementation MASTSViewController

- (void)dealloc
{
    // To be safe, always reset the delegate
    [self.adView setDelegate:nil];
    self.adView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Now that the storyboard has loaded the view, add the ad to the top using
    // lazy creation and setup.  Reuse if already setup.
    if (self.adView == nil)
    {
        self.adView = [[MASTAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        // Like a normal view setup autoresizing for autorotation changes
        self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Set some obvious background color (MASTAdView is a UIView)
        self.adView.backgroundColor = [UIColor darkGrayColor];
        
        self.adView.site = 19829;
        self.adView.zone = 98463;
        
        self.updateAdView = YES;
    }
    
    [self.view addSubview:self.adView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.updateAdView)
    {
        self.updateAdView = NO;
        
        // Update now and every 20 seconds.
        [self.adView updateWithTimeInterval:20];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Reset/stop the ad view from updating.
    // Reset the updateAdView flag so when the view appears again it will start updating again.
    [self.adView reset];
    self.updateAdView = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
