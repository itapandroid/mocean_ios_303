//
//  MASTSMenuController.h
//  MASTSamples
//
//  Created on 4/16/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTSMenuController;


@protocol MASTSMenuDelegate <NSObject>
@required

- (void)menuController:(MASTSMenuController*)menuController presentController:(UIViewController*)controller;

@end


@interface MASTSMenuController : UITableViewController


@property (nonatomic, assign) id<MASTSMenuDelegate> delegate;

@end
