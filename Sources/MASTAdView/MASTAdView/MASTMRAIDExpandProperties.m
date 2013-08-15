//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.
//

#import "MASTMRAIDExpandProperties.h"

static NSString* MASTMRAIDExpandPropertiesWidth = @"width";
static NSString* MASTMRAIDExpandPropertiesHeight = @"height";
static NSString* MASTMRAIDExpandPropertiesUseCustomClose = @"useCustomClose";

@implementation MASTMRAIDExpandProperties

@synthesize width, height, useCustomClose;


+ (MASTMRAIDExpandProperties*)propertiesFromArgs:(NSDictionary*)args
{
    MASTMRAIDExpandProperties* properties = [MASTMRAIDExpandProperties new];
    
    // TODO: The boolean checks will be set to false if the value is anything else other than true or unset.
    // Some of them need to default to true if unset so the logic should be updated to check the unset
    // condition or default everything to it's defaults and only set them if set to something.

    properties.width = [[args valueForKey:MASTMRAIDExpandPropertiesWidth] integerValue];
    properties.height = [[args valueForKey:MASTMRAIDExpandPropertiesHeight] integerValue];
    properties.useCustomClose = [[args valueForKey:MASTMRAIDExpandPropertiesUseCustomClose] isEqualToString:@"true"];

    return properties;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.width = 0;
        self.height = 0;
        self.useCustomClose = false;
    }
    return self;
}

- (id)initWithSize:(CGSize)size
{
    self = [self init];
    if (self)
    {
        self.width = size.width;
        self.height = size.height;
    }
    return self;
}

- (NSString*)description
{
    NSString* ucc = @"false";
    if (self.useCustomClose)
        ucc = @"true";
    
    NSString* desc = [NSString stringWithFormat:@"{width:%d,height:%d,useCustomClose:%@}", self.width, self.height, ucc];
    
    return desc;
}

@end
