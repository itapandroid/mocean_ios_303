//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012, 2013 Mocean Mobile. All rights reserved.
//

#import "MASTAdBrowser.h"
#import "MASTBrowserBackPNG.h"
#import "MASTBrowserForwardPNG.h"


@interface MASTAdBrowser () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, strong) UIToolbar* toolbar;
@property (nonatomic, strong) UIBarButtonItem* backButton;
@property (nonatomic, strong) UIBarButtonItem* forwardButton;
@end

@implementation MASTAdBrowser

@synthesize delegate, URL;
@synthesize webView, toolbar, backButton, forwardButton;

- (void)dealloc
{
    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.toolbar == nil)
    {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 44,
                                                                   CGRectGetWidth(self.view.bounds), 44)];
        
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        self.toolbar.barStyle = UIBarStyleBlack;
        
        NSMutableArray* items = [NSMutableArray array];
        
        // Close
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                              target:self
                                                                              action:@selector(toolbarClose:)];
        [items addObject:item];
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        // Back
        NSData* buttonData = [NSData dataWithBytesNoCopy:MASTBrowserBack_png
                                                  length:MASTBrowserBack_png_len
                                            freeWhenDone:NO];
        
        UIImage* buttonImage = [UIImage imageWithData:buttonData];
        buttonImage = [UIImage imageWithCGImage:buttonImage.CGImage
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
        
        item = [[UIBarButtonItem alloc] initWithImage:buttonImage
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(toolbarBack:)];
        
        [items addObject:item];
        self.backButton = item;
        self.backButton.enabled = NO;
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        

        // Forward
        buttonData = [NSData dataWithBytesNoCopy:MASTBrowserForward_png
                                          length:MASTBrowserForward_png_len
                                    freeWhenDone:NO];
        
        buttonImage = [UIImage imageWithData:buttonData];
        buttonImage = [UIImage imageWithCGImage:buttonImage.CGImage
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
        
        item = [[UIBarButtonItem alloc] initWithImage:buttonImage
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(toolbarForward:)];
        [items addObject:item];
        self.forwardButton = item;
        self.forwardButton.enabled = NO;
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        
        // Reload
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                             target:self
                                                             action:@selector(toolbarReload:)];
        [items addObject:item];
        
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
        [items addObject:item];
        
        
        // Action
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                             target:self
                                                             action:@selector(toolbarAction:)];
        [items addObject:item];
        
        
        self.toolbar.items = items;
    }
    
    if (self.webView == nil)
    {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.webView.delegate = self;
        self.webView.allowsInlineMediaPlayback = YES;
        self.webView.mediaPlaybackRequiresUserAction = YES;
    }
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.toolbar];
}

- (void)setURL:(NSURL *)url
{
    URL = [url copy];
    [self load];
}

- (void)load
{
    if (self.isViewLoaded == NO)
        return;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.URL
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:10];
    
    [self.webView loadRequest:request];
}

#pragma mark - Toolbar Selectors

- (void)toolbarClose:(id)sender
{
    [self.delegate MASTAdBrowserClose:self];
}

- (void)toolbarBack:(id)sender
{
    [self.webView goBack];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarForward:(id)sender
{
    [self.webView goForward];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarReload:(id)sender
{
    [self.webView reload];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)toolbarAction:(id)sender
{
    [self.delegate MASTAdBrowserWillLeaveApplication:self];
    
    [[UIApplication sharedApplication] openURL:[self.webView.request URL]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    [self.delegate MASTAdBrowser:self didFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* host = [request.URL.host lowercaseString];

    if ([host hasSuffix:@"itunes.apple.com"] || [host hasSuffix:@"phobos.apple.com"])
    {
        // TODO: May need to follow all redirects to determine if it's an itunes link.
        // http://developer.apple.com/library/ios/#qa/qa1629/_index.html
        
        [self.delegate MASTAdBrowserWillLeaveApplication:self];
        
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        return NO;
    }
    
    return YES;
}

@end
