//
//  MASTSAdConfigPrompt.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSAdConfigPrompt.h"

@interface MASTSAdConfigPrompt() <UIAlertViewDelegate>
@property (nonatomic, assign) id<MASTSAdConfigPromptDelegate> delegate;
@property (nonatomic, strong) UITextField* siteField;
@property (nonatomic, strong) UITextField* zoneField;
@end

@implementation MASTSAdConfigPrompt

@synthesize delegate, siteField, zoneField;

- (void)dealloc
{
    self.siteField = nil;
    self.zoneField = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (id)initWithDelegate:(id<MASTSAdConfigPromptDelegate>)d site:(NSInteger)site zone:(NSInteger)zone;
{
    self = [super initWithTitle:@"Site and Zone"
                        message:@"\n\n"
                       delegate:nil
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"Refresh", nil];
    if (self)
    {
        self.delegate = d;
        
        self.siteField = [[[UITextField alloc] initWithFrame:CGRectMake(12, 45, 118, 31)] autorelease];
        [self.siteField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[self.siteField setBorderStyle:UITextBorderStyleRoundedRect];
		[self.siteField setBackgroundColor:[UIColor clearColor]];
        [self.siteField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.siteField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.siteField setPlaceholder:@"Site"];
        [self addSubview:self.siteField];
        
        self.zoneField = [[[UITextField alloc] initWithFrame:CGRectMake(154, 45, 118, 31)] autorelease];
        [self.zoneField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[self.zoneField setBorderStyle:UITextBorderStyleRoundedRect];
		[self.zoneField setBackgroundColor:[UIColor clearColor]];
        [self.zoneField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.zoneField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.zoneField setPlaceholder:@"Zone"];
        [self addSubview:self.zoneField];
        
        NSString* sysVersion = [[[UIDevice currentDevice] systemVersion] substringToIndex:1];
        if ([sysVersion integerValue] >= 5)
        {
            [self.siteField setBackgroundColor:[UIColor whiteColor]];
            [self.zoneField setBackgroundColor:[UIColor whiteColor]];
        }
        
        [super setDelegate:self];
        
        if (site != 0)
            self.siteField.text = [NSString stringWithFormat:@"%d", site];
        
        if (zone != 0)
            self.zoneField.text = [NSString stringWithFormat:@"%d", zone];
    }
    return self;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    [self.delegate configPromptCancel:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex)
    {
        [self.delegate configPromptCancel:self];
        return;
    }

    [self.delegate configPrompt:self
                refreshWithSite:[self.siteField.text integerValue]
                           zone:[self.zoneField.text integerValue]];
}

@end
