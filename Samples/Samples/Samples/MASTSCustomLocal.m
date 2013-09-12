//
//  MASTSCustomLocal.m
//  Samples
//
//  Created on 11/20/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSCustomLocal.h"

@interface MASTSCustomLocal ()

@end

@implementation MASTSCustomLocal

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger zone = 0;
    
    super.adView.zone = zone;
    
    // A bit goofy but keeps setFirstAppear hidden in the parent class and
    // overrides it to not do an update since the zone is invalid given
    // the goal of this sample is to show locally derived ad content.
    BOOL value = NO;
    SEL sel = @selector(setFirstAppear:);
    NSMethodSignature* sig = [super methodSignatureForSelector:sel];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:sel];
    [invocation setArgument:&value atIndex:2];
    [invocation invoke];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* content = @"<div align='center'><script src=\"mraid.js\"></script><script type='text/javascript'>function showAd(){} function openUrl(){mraid.open('https://itunes.apple.com/us/app/find-my-friends/id466122094?mt=8&uo=4');} if (mraid.getState() == 'loading'){mraid.addEventListener('ready',showAd);}else{showAd();}</script></head><body style='margin:0;border:0;'><span style='size:10px;' onclick='openUrl();'>Open</span></div>";
    
    MASTMoceanAdDescriptor* descriptor = [MASTMoceanAdDescriptor descriptorWithRichMediaContent:content];
    
    [super.adView renderWithAdDescriptor:descriptor];
}

@end
