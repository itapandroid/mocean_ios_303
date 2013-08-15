//
//  MASTSMainViewController.m
//  InstallationDirect
//
//  Created on 10/11/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import "MASTSMainViewController.h"

#import "MASTAdView.h"

@interface MASTSMainViewController () <MASTAdViewDelegate>

// Reference to the ad view
// Using a property for easy reference management
@property (nonatomic, retain) MASTAdView* adView;

// Using this to track when the ad view should update
@property (nonatomic, assign) BOOL updateAdView;

@end

@implementation MASTSMainViewController

- (void)dealloc
{
    // Always reset the delegate and release the ad view.
    // This guarantees that even if something else is still holding on to the
    //  ad view that this controller will no longer be the delegate since it's
    //  being deallocated.
    // Note that even if adView is nil it can be sent messages.
    [self.adView setDelegate:nil];
    self.adView = nil;
    
    
    [_flipsidePopoverController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Now that the storyboard has loaded the view, add the ad to the top using
    // lazy creation and setup.  Reuse if already setup.
    if (self.adView == nil)
    {
        // Note that the autorelease is here becuase assigning to the retain property will retain the
        // ad view.  After the event loop purges the autorelease pool the retain count will be one
        // plus any retaining addSubview will do later.
        self.adView = [[[MASTAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
        
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

#pragma mark - MASTAdViewDelegate

- (void)MASTAdViewDidRecieveAd:(MASTAdView *)adView
{
    NSLog(@"MASTAdViewDidRecieveAd");
}

- (void)MASTAdView:(MASTAdView *)adView didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"MASTAdView:didFailToReceiveAdWithError:%@", error);
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(MASTSFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
