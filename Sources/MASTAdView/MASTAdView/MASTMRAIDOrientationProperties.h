//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    MASTMRAIDOrientationPropertiesForceOrientationPortrait = 0,
    MASTMRAIDOrientationPropertiesForceOrientationLandscape,
    MASTMRAIDOrientationPropertiesForceOrientationNone,
}MASTMRAIDOrientationPropertiesForceOrientation;


@interface MASTMRAIDOrientationProperties : NSObject

+ (MASTMRAIDOrientationProperties*)propertiesFromArgs:(NSDictionary*)args;

- (id)init;

@property (nonatomic, assign) BOOL allowOrientationChange;
@property (nonatomic, assign) MASTMRAIDOrientationPropertiesForceOrientation forceOrientation;

@end
