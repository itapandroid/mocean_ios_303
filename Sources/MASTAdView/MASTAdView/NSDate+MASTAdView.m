//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//


#import "NSDate+MASTAdView.h"
#import <time.h>
#import <xlocale.h>


@implementation NSDate (MASTAdView)

static NSCharacterSet* tzMarkerCharacterSet = nil;

// Expects something like: 2012-12-21T10:30:15-0500
+ (id)dateFromW3CCalendarDate:(NSString*)dateString
{
    if (tzMarkerCharacterSet == nil)
        tzMarkerCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    
    if ([dateString length] == 0)
        return nil;
    
    // Needs to have a date and time.
    NSArray* dateAndTime = [dateString componentsSeparatedByString:@"T"];
    if ([dateAndTime count] != 2)
        return nil;
    
    NSString* time = [dateAndTime objectAtIndex:1];
    if ([time hasSuffix:@"Z"])
    {
        // Swap Z for the GMT offset.
        time = [time stringByReplacingOccurrencesOfString:@"Z" withString:@"+0000"];
    }
    else
    {
        NSRange tzMarker = [time rangeOfCharacterFromSet:tzMarkerCharacterSet];
        if (tzMarker.location != NSNotFound)
        {
            // Remove the : from the zone offset.
            NSString* zone = [time substringFromIndex:tzMarker.location];
            NSString* fixedZone = [zone stringByReplacingOccurrencesOfString:@":" withString:@""];
            
            time = [time stringByReplacingOccurrencesOfString:zone withString:fixedZone];
            
            // Add in zero'd seconds if seconds are missing.
            if ([[time componentsSeparatedByString:@":"] count] < 3)
            {
                tzMarker.length = 0;
                time = [time stringByReplacingCharactersInRange:tzMarker withString:@":00"];
            }
        }
        else
        {
            // Add a GMT offset so "something" is there.
            time = [time stringByAppendingString:@"+0000"];
        }
    }

    NSString* fixedDateString = [NSString stringWithFormat:@"%@T%@", 
                                 [dateAndTime objectAtIndex:0],
                                 time];
    
    struct tm parsedTime;
    const char* formatString = "%FT%T%z";
    strptime_l([fixedDateString UTF8String], formatString, &parsedTime, NULL);
    time_t since = mktime(&parsedTime);
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:since];
    
    return date;
}

@end
