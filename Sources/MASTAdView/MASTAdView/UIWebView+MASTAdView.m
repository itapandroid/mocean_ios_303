//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//


#import "UIWebView+MASTAdView.h"

@implementation UIWebView (MASTAdView)

- (void)disableScrolling
{
    UIScrollView* scrollView = nil;
    
    if ([self respondsToSelector:@selector(scrollView)])
    {
        scrollView = [self scrollView];
    }
    else
    {
        for (id sv in [self subviews])
        {
            if ([sv isKindOfClass:[UIScrollView class]])
            {
                scrollView = sv;
                break;
            }
        }
    }

    [scrollView setContentInset:UIEdgeInsetsZero];
    [scrollView setScrollEnabled:NO];
    [scrollView setBounces:NO];
}

- (void)disableSelection
{
    NSString * js = @"window.getSelection().removeAllRanges();";
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)scrollToTop
{
    UIScrollView* scrollView = nil;
    
    if ([self respondsToSelector:@selector(scrollView)])
    {
        scrollView = [self scrollView];
    }
    else
    {
        for (id sv in [self subviews])
        {
            if ([sv isKindOfClass:[UIScrollView class]])
            {
                scrollView = sv;
                break;
            }
        }
    }
    
    [scrollView setContentOffset:CGPointZero animated:NO];
}

@end
