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
    
    NSInteger site = 0;
    NSInteger zone = 0;
    
    super.adView.site = site;
    super.adView.zone = zone;
    
    // A bit goofy but keeps setFirstAppear hidden in the parent class and
    // overrides it to not do an update since the site and zone are invalid
    // given the goal of this sample is to show locally derived ad content.
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
    
    NSString* content = @"<html><head><style type='text/css'>body{background-color:orange;}</style><script src=\"mraid.js\"></script><script type='text/javascript'>function showAd(){} function openUrl(){mraid.open('http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=284417350&mt=8');} if (mraid.getState() == 'loading'){mraid.addEventListener('ready',showAd);}else{showAd();}</script></head><body style='margin:0;border:0;'><div align='center'><span style='size:10px;' onclick='openUrl();'>Open</span></div></body></html>";
    
    MASTMoceanAdDescriptor* descriptor = [MASTMoceanAdDescriptor descriptorWithRichMediaContent:content];
    
    [super.adView renderWithAdDescriptor:descriptor];
}

@end
