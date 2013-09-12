//
//  MASTSSimple.m
//  MASTSamples
//
//  Created on 4/16/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimple.h"


@interface MASTSSimple () 
@property (nonatomic, assign) BOOL firstAppear;
@end


@implementation MASTSSimple

@synthesize adView;
@synthesize firstAppear;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.adView reset];
    [self.adView setDelegate:nil];
    self.adView = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        self.firstAppear = YES;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    }
    return self;
}

- (void)refresh:(id)sender
{
    MASTSAdConfigPrompt* prompt = [[[MASTSAdConfigPrompt alloc] initWithDelegate:self
                                                                           zone:self.adView.zone] autorelease];
    [prompt show];
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
    // Setup (or possibly resetup) the ad view.
    
    [self.adView reset];
    [self.adView removeFromSuperview];
    
    CGRect frame = self.view.bounds;
    frame.size.height = 50;
    self.adView = [[[MASTAdView alloc] initWithFrame:frame] autorelease];
    self.adView.backgroundColor = [UIColor lightGrayColor];
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.adView.logLevel = MASTAdViewLogEventTypeDebug;
    [self.view addSubview:self.adView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.firstAppear)
    {
        self.firstAppear = NO;
        
        if (self.adView.zone > 0)
        {
            [self.adView update];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}

#pragma mark -

- (void)configPrompt:(MASTSAdConfigPrompt *)prompt refreshWithZone:(NSInteger)zone
{
    self.adView.zone = zone;
    
    [self.adView update];
}

- (void)configPromptCancel:(MASTSAdConfigPrompt *)prompt
{
    
}

@end
