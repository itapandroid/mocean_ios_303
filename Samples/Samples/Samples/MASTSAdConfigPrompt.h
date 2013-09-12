//
//  MASTSAdConfigPrompt.h
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASTSAdConfigPrompt;

@protocol MASTSAdConfigPromptDelegate <NSObject>
@required

- (void)configPromptCancel:(MASTSAdConfigPrompt*)prompt;
- (void)configPrompt:(MASTSAdConfigPrompt*)prompt refreshWithSite:(NSInteger)site zone:(NSInteger)zone;

@end

@interface MASTSAdConfigPrompt : UIAlertView

- (id)initWithDelegate:(id<MASTSAdConfigPromptDelegate>)delegate site:(NSInteger)site zone:(NSInteger)zone;

@end
