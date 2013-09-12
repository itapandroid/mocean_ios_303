//
//  MASTSDelegateInternalBrowser.m
//  Samples
//
//  Created on 6/13/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateInternalBrowser.h"

@interface MASTSDelegateInternalBrowser ()

@end

@implementation MASTSDelegateInternalBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSInteger zone = 88269;
    
    self.adView.zone = zone;
    self.adView.useInternalBrowser = YES;
    self.adView.logLevel = MASTADViewLogEventTypeNone;
}

@end
