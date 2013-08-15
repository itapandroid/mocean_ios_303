//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import "MASTMRAIDOrientationProperties.h"

static NSString* MASTMRAIDOrientationPropertiesAllowOrientationChange = @"allowOrientationChange";
static NSString* MASTMRAIDOrientationPropertiesFOrientation = @"forceOrientation";

static NSString* MASTMRAIDOrientationPropertiesFOrientationPortrait = @"portrait";
static NSString* MASTMRAIDOrientationPropertiesFOrientationLandscape = @"landscape";
static NSString* MASTMRAIDOrientationPropertiesFOrientationNone = @"none";


@implementation MASTMRAIDOrientationProperties

@synthesize allowOrientationChange, forceOrientation;


+ (MASTMRAIDOrientationProperties*)propertiesFromArgs:(NSDictionary*)args
{
    MASTMRAIDOrientationProperties* properties = [MASTMRAIDOrientationProperties new];
    
    // TODO: The boolean checks will be set to false if the value is anything else other than true or unset.
    // Some of them need to default to true if unset so the logic should be updated to check the unset
    // condition or default everything to it's defaults and only set them if set to something.
    
    properties.allowOrientationChange = ![[args valueForKey:MASTMRAIDOrientationPropertiesAllowOrientationChange] isEqualToString:@"false"];
    
    properties.forceOrientation = MASTMRAIDOrientationPropertiesForceOrientationNone;
    NSString* fo = [args valueForKey:MASTMRAIDOrientationPropertiesFOrientation];
    if ([fo isEqualToString:MASTMRAIDOrientationPropertiesFOrientationPortrait])
    {
        properties.forceOrientation = MASTMRAIDOrientationPropertiesForceOrientationPortrait;
    }
    else if ([fo isEqualToString:MASTMRAIDOrientationPropertiesFOrientationLandscape])
    {
        properties.forceOrientation = MASTMRAIDOrientationPropertiesForceOrientationLandscape;
    }
    
    return properties;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.allowOrientationChange = true;
        self.forceOrientation = MASTMRAIDOrientationPropertiesForceOrientationNone;
    }
    return self;
}

- (NSString*)description
{
    NSString* aoc = @"false";
    if (self.allowOrientationChange)
        aoc = @"true";
    
    NSString* fo = nil;
    switch (self.forceOrientation)
    {
        case MASTMRAIDOrientationPropertiesForceOrientationPortrait:
            fo = MASTMRAIDOrientationPropertiesFOrientationPortrait;
            break;
            
        case MASTMRAIDOrientationPropertiesForceOrientationLandscape:
            fo = MASTMRAIDOrientationPropertiesFOrientationLandscape;
            break;
            
        default:
            fo = MASTMRAIDOrientationPropertiesFOrientationNone;
            break;
    }
    
    NSString* desc = [NSString stringWithFormat:@"{allowOrientationChange:%@,forceOrientation:'%@'}", aoc, fo];
    
    return desc;
}

@end
