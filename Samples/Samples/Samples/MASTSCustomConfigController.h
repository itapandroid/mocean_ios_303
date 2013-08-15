//
//  MASTSCustomConfigController.h
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTSCustomConfigController;

@protocol MASTSCustomConfigDelegate <NSObject>
@required
- (void)cancelCustomConfig:(MASTSCustomConfigController*)controller;
- (void)customConfig:(MASTSCustomConfigController*)controller updatedWithConfig:(NSDictionary*)settings;

@end


@interface MASTSCustomConfigController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<MASTSCustomConfigDelegate> delegate;

- (void)setConfig:(NSDictionary*)config;

@end
