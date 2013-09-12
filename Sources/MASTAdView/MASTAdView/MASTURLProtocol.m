//
//  MASTURLProtocol.m
//  MASTAdView
//
//  Created on 6/19/13.
//  Copyright (c) 2013 Mocean Mobile. All rights reserved.
//

#import "MASTURLProtocol.h"
#import "MASTMRAIDControllerJS.h"

@implementation MASTURLProtocol

static NSData* mraidScriptData = nil;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSURL* url = [request URL];
    NSString* scheme = [url scheme];
    
    if ([scheme isEqualToString:@"applewebdata"] || [scheme hasPrefix:@"http"])
    {
        if ([[url absoluteString] hasSuffix:@"mraid.js"])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self)
    {
        
    }
    return self;
}

- (void)startLoading
{
    if (mraidScriptData == nil)
    {
        mraidScriptData = [NSData dataWithBytesNoCopy:MASTMRAIDController_js
                                               length:MASTMRAIDController_js_len
                                         freeWhenDone:NO];
    }
    
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:[[self request] URL]
                                                        MIMEType:@"application/javascript"
                                           expectedContentLength:[mraidScriptData length]
                                                textEncodingName:@"UTF-8"];
    
    id<NSURLProtocolClient> client = [self client];
    
    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:mraidScriptData];
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    
}

@end
