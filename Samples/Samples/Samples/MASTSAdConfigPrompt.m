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
@property (nonatomic, strong) UITextField* zoneField;
@end

@implementation MASTSAdConfigPrompt

@synthesize delegate, zoneField;

- (void)dealloc
{
    self.zoneField = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (id)initWithDelegate:(id<MASTSAdConfigPromptDelegate>)d zone:(NSInteger)zone;
{
    self = [super initWithTitle:@"Zone"
                        message:@"\n\n"
                       delegate:nil
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"Refresh", nil];
    if (self)
    {
        self.delegate = d;
        
        self.zoneField = [[[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 31)] autorelease];
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
            [self.zoneField setBackgroundColor:[UIColor whiteColor]];
        }
        
        [super setDelegate:self];

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

    [self.delegate configPrompt:self refreshWithZone:[self.zoneField.text integerValue]];
}

@end
