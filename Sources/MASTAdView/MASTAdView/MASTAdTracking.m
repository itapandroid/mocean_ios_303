//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import "MASTAdTracking.h"
#import "MASTDefaults.h"
#import "MASTConstants.h"


@interface MASTAdTracking()
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSString* userAgent;
@end


@implementation MASTAdTracking

@synthesize connection, userAgent;

- (void)dealloc
{
    self.connection = nil;
}

- (id)initWithURL:(NSURL*)url userAgent:(NSString*)ua
{
    self = [super init];
    if (self)
    {
        self.userAgent = ua;
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                timeoutInterval:MAST_DEFAULT_NETWORK_TIMEOUT];
        
        [request setValue:self.userAgent forHTTPHeaderField:MASTUserAgentHeader];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (self.connection == nil)
        {
            self.userAgent = nil;
            return nil;
        }
    }
    return self;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    if (conn == self.connection)
    {
        self.connection = nil;
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    NSMutableURLRequest* mutableRequest = [request mutableCopy];
    
    [mutableRequest setValue:self.userAgent forHTTPHeaderField:MASTUserAgentHeader];
    
    return mutableRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    if (conn == self.connection)
    {
        self.connection = nil;
    }
}

@end
