//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface MASTMoceanAdResponse : NSObject <NSXMLParserDelegate>


- (id)initWithXML:(NSData*)xmlData;

- (void)parse;

@property (nonatomic, readonly) NSArray* adDescriptors;

@property (nonatomic, strong) NSString* errorCode;
@property (nonatomic, strong) NSString* errorMessage;

@end
