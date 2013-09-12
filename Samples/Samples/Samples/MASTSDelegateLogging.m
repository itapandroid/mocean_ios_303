//
//  MASTSDelegateLogging.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateLogging.h"

@interface MASTSDelegateLogging ()

@end

@implementation MASTSDelegateLogging

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 88269;
    
    self.adView.zone = zone;
    self.adView.logLevel = MASTAdViewLogEventTypeDebug;
}

- (void)writeEntry:(NSString*)entry
{
    // Overridden to prevent writing other delegate output since this controller just shows log output.
}

#pragma mark MASTAdViewDelegate

static NSDateFormatter* dateFormatter = nil;

- (BOOL)MASTAdView:(MASTAdView *)adView shouldLogEvent:(NSString *)event ofType:(MASTAdViewLogEventType)type
{
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }

    NSString* entry = [NSString stringWithFormat:@"%@\n%@", [dateFormatter stringFromDate:[NSDate date]], event];
    
    [super writeEntry:entry];
    
    // Returning YES to tell the MASTAdView instance to also send this event to the NSLog console.
    return YES;
}

@end
