//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    MASTMRAIDResizeCustomClosePositionTopLeft = 0,
    MASTMRAIDResizeCustomClosePositionTopCenter,
    MASTMRAIDResizeCustomClosePositionTopRight,
    MASTMRAIDResizeCustomClosePositionCenter,
    MASTMRAIDResizeCustomClosePositionBottomLeft,
    MASTMRAIDResizeCustomClosePositionBottomCenter,
    MASTMRAIDResizeCustomClosePositionBottomRight
}MASTMRAIDResizeCustomClosePosition;


@interface MASTMRAIDResizeProperties : NSObject

+ (MASTMRAIDResizeProperties*)propertiesFromArgs:(NSDictionary*)args;

- (id)init;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) MASTMRAIDResizeCustomClosePosition customClosePosition;
@property (nonatomic, assign) NSInteger offsetX;
@property (nonatomic, assign) NSInteger offsetY;
@property (nonatomic, assign) BOOL allowOffscreen;

@end
