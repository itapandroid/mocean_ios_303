//
//  MASTSCustom.m
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSCustom.h"
#import "MASTSCustomConfigController.h"


@interface MASTSCustom ()
@property (nonatomic, retain) UIPopoverController* configPopoverController;
@end

@implementation MASTSCustom

@synthesize configPopoverController;

- (void)dealloc
{
    self.configPopoverController = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {   
        UISegmentedControl* seg = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Menu", @"Refresh", nil]] autorelease];
        seg.segmentedControlStyle = UISegmentedControlStyleBar;
        seg.momentary = YES;
        [seg addTarget:self action:@selector(barMenu:) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem* segButton = [[[UIBarButtonItem alloc] initWithCustomView:seg] autorelease];
        
        self.navigationItem.rightBarButtonItem = segButton;
    }
    return self;
}

- (void)barMenu:(UISegmentedControl*)seg
{
    switch (seg.selectedSegmentIndex)
    {
        case 0: // menu
            [self menu:seg];
            break;
            
        case 1: // refresh (this is a hack since we know refresh exits)
            [self performSelector:@selector(refresh:) withObject:seg];
            break;
    }
}

- (void)loadView
{
    [super loadView];
    
    // Adjust for the status bar, the navigation bar space will trigger an update layout.
    CGRect adjustedFrame = [[UIScreen mainScreen] bounds];
    CGRect adjustedBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        adjustedFrame = CGRectMake(adjustedFrame.origin.x, adjustedFrame.origin.y,
                                   adjustedFrame.size.height, adjustedFrame.size.width);
        
        adjustedBarFrame = CGRectMake(adjustedBarFrame.origin.x, adjustedBarFrame.origin.y,
                                      adjustedBarFrame.size.height, adjustedBarFrame.size.width);
        
    }
    //adjustedFrame.size.height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
    adjustedFrame.size.height -= adjustedBarFrame.size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 156037;
    
    super.adView.site = site;
    super.adView.zone = zone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.configPopoverController dismissPopoverAnimated:NO];
}

#pragma mark -

- (void)menu:(id)sender
{
    MASTSCustomConfigController* configController = [[MASTSCustomConfigController new] autorelease];
    configController.delegate = self;
    
    NSMutableDictionary* config = [NSMutableDictionary dictionary];
    [config setValue:[NSNumber numberWithInteger:self.adView.frame.origin.x] forKey:@"x"];
    [config setValue:[NSNumber numberWithInteger:self.adView.frame.origin.y] forKey:@"y"];
    [config setValue:[NSNumber numberWithInteger:self.adView.frame.size.width] forKey:@"width"];
    [config setValue:[NSNumber numberWithInteger:self.adView.frame.size.height] forKey:@"height"];
    [config setValue:[NSNumber numberWithBool:self.adView.useInternalBrowser] forKey:@"useInteralBrowser"];
    [configController setConfig:config];
    
    UINavigationController* navController = [[[UINavigationController alloc] initWithRootViewController:configController] autorelease];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self presentModalViewController:navController animated:YES];
    }
    else
    {
        self.configPopoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        [self.configPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -

- (void)cancelCustomConfig:(MASTSCustomConfigController *)controller
{
    if (self.configPopoverController != nil)
    {
        [self.configPopoverController dismissPopoverAnimated:YES];
        self.configPopoverController = nil;
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)customConfig:(MASTSCustomConfigController *)controller updatedWithConfig:(NSDictionary *)settings
{
    if (self.configPopoverController != nil)
    {
        [self.configPopoverController dismissPopoverAnimated:YES];
        self.configPopoverController = nil;
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    CGRect frame = CGRectMake([[settings valueForKey:@"x"] integerValue],
                              [[settings valueForKey:@"y"] integerValue],
                              [[settings valueForKey:@"width"] integerValue],
                              [[settings valueForKey:@"height"] integerValue]);
    self.adView.frame = frame;


    id value = [settings valueForKey:@"useInternalBrowser"];
    self.adView.useInternalBrowser = [value boolValue];
    
    [self.adView update];
}

@end
