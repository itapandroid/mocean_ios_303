//
//  MASTSFlipsideViewController.m
//  InstallationDirect
//
//  Created on 10/11/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import "MASTSFlipsideViewController.h"

@interface MASTSFlipsideViewController ()

@end

@implementation MASTSFlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
