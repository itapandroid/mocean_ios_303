//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MASTMoceanAdDescriptor : NSObject <NSXMLParserDelegate>

+ (id)descriptorWithRichMediaContent:(NSString*)content;

- (id)initWithParser:(NSXMLParser*)parser attributes:(NSDictionary*)attributes;

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* url;
@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) NSString* img;
@property (nonatomic, readonly) NSString* content;
@property (nonatomic, readonly) NSString* track;


@end
