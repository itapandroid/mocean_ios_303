//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MASTMRAIDExpandProperties : NSObject

+ (MASTMRAIDExpandProperties*)propertiesFromArgs:(NSDictionary*)args;

- (id)init;
- (id)initWithSize:(CGSize)size;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) BOOL useCustomClose;

@end
