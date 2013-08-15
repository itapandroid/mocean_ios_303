//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import "MASTMoceanAdResponse.h"
#import "MASTMoceanAdDescriptor.h"


@interface MASTMoceanAdResponse()
@property (nonatomic, strong) NSMutableArray* descriptors;
@property (nonatomic, strong) NSXMLParser* xmlParser;
@property (nonatomic, strong) MASTMoceanAdDescriptor* parsingDescriptor;
@end


@implementation MASTMoceanAdResponse

@synthesize descriptors, xmlParser, errorCode, errorMessage, parsingDescriptor;

- (void)dealloc
{
    [self.xmlParser setDelegate:nil];
    self.xmlParser = nil;
}

- (id)initWithXML:(NSData*)xmlData
{
    self = [super init];
    if (self)
    {
        self.xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
        self.xmlParser.delegate = self;
        
        self.descriptors = [NSMutableArray new];
    }
    return self;
}

- (void)parse
{
    [self.xmlParser parse];
    [self.xmlParser setDelegate:nil];
    self.xmlParser = nil;
}

- (NSArray*)adDescriptors
{
    [self parse];
    
    return self.descriptors;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([@"ad" isEqualToString:elementName])
    {
        self.parsingDescriptor = [[MASTMoceanAdDescriptor alloc] initWithParser:parser attributes:attributeDict];
    }
    else if ([@"error" isEqualToString:elementName])
    {
        self.errorCode = [attributeDict valueForKey:@"code"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ((self.parsingDescriptor != nil) && [@"ad" isEqualToString:elementName])
    {
        [self.descriptors addObject:self.parsingDescriptor];
        self.parsingDescriptor = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.errorCode != nil)
    {
        if (self.errorMessage == nil)
        {
            self.errorMessage = string;
        }
        else
        {
            self.errorMessage = [self.errorMessage stringByAppendingString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
}

@end
