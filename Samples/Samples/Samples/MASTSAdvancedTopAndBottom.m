//
//  MASTSAdvancedTopAndBottom.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSAdvancedTopAndBottom.h"

@interface MASTSAdvancedTopAndBottom ()
@property (nonatomic, retain) MASTAdView* bottomAdView;
@property (nonatomic, assign) BOOL bottomFirstAppear;
@end

@implementation MASTSAdvancedTopAndBottom

@synthesize bottomAdView, bottomFirstAppear;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.bottomFirstAppear = YES;
        
        UISegmentedControl* seg = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Top", @"Bottom", nil]] autorelease];
        seg.segmentedControlStyle = UISegmentedControlStyleBar;
        seg.momentary = YES;
        [seg addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem* segButton = [[[UIBarButtonItem alloc] initWithCustomView:seg] autorelease];
        
        self.navigationItem.rightBarButtonItem = segButton;
    }
    return self;
}

- (void)refresh:(UISegmentedControl*)seg
{
    MASTAdView* adViewToConfigure = nil;
    
    switch (seg.selectedSegmentIndex)
    {
        case 0: // top
            adViewToConfigure = self.adView;
            break;
        case 1: // bottom
            adViewToConfigure = self.bottomAdView;
            break;
    }
    
    MASTSAdConfigPrompt* prompt = [[[MASTSAdConfigPrompt alloc] initWithDelegate:self
                                                                            site:adViewToConfigure.site
                                                                            zone:adViewToConfigure.zone] autorelease];
    // use the tag to pass the top/bottom notion to the prompt handler
    prompt.tag = seg.selectedSegmentIndex;
    
    [prompt show];
}

- (void)loadView
{
    [super loadView];
    
    CGRect frame = super.adView.frame;
    super.adView.frame = frame;
    super.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    // Setup (or possibly resetup) the BOTTOM ad view (super covers the adView)
    [self.bottomAdView reset];
    [self.bottomAdView removeFromSuperview];
    
    frame = super.adView.frame;
    frame.size.width = CGRectGetWidth(super.view.bounds);
    frame.origin.y = CGRectGetMaxY(super.view.bounds) - frame.size.height;
    
    self.bottomAdView = [[[MASTAdView alloc] initWithFrame:frame] autorelease];
    self.bottomAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.bottomAdView.backgroundColor = self.adView.backgroundColor;
    [self.view addSubview:self.bottomAdView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger topSite = 19829;
    NSInteger topZone = 102238;
    NSInteger bottomSite = 19829;
    NSInteger bottomZone = 88269;
    
    super.adView.site = topSite;
    super.adView.zone = topZone;
    self.bottomAdView.site = bottomSite;
    self.bottomAdView.zone = bottomZone;
    
    super.adView.backgroundColor = [UIColor clearColor];
    self.bottomAdView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.bottomFirstAppear)
    {
        self.bottomFirstAppear = NO;
        [self.bottomAdView update];
    }
}

#pragma mark -

- (void)configPrompt:(MASTSAdConfigPrompt *)prompt refreshWithSite:(NSInteger)site zone:(NSInteger)zone
{
    if (prompt.tag == 0)
    {
        [super configPrompt:prompt refreshWithSite:site zone:zone];
        return;
    }
    
    self.bottomAdView.site = site;
    self.bottomAdView.zone = zone;
    
    [self.bottomAdView update];
}

@end
