//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import "MASTMoceanThirdPartyDescriptor.h"

@interface MASTMoceanThirdPartyDescriptor()
@property (nonatomic, strong) NSMutableArray* elementStack;
@property (nonatomic, strong) NSMutableDictionary* elementValues;
@property (nonatomic, strong) NSMutableDictionary* campaignParams;
@property (nonatomic, strong) NSMutableString* stringBuffer;
@property (nonatomic, strong) NSDictionary* elementAttributes;
@end

@implementation MASTMoceanThirdPartyDescriptor

@synthesize elementStack, elementValues, campaignParams, stringBuffer, elementAttributes;

- (id)initWithClientSideExternalCampaign:(NSString*)content
{
    self = [super init];
    if (self)
    {
        self.elementStack = [NSMutableArray new];
        self.elementValues = [NSMutableDictionary new];
        self.campaignParams = [NSMutableDictionary new];
        
        NSRange start = [content rangeOfString:@"<external_campaign"];
        if (start.location != NSNotFound)
        {
            NSRange end = [content rangeOfString:@"</external_campaign>"];
            start.length = end.location - start.location + 20;
            
            content = [content substringWithRange:start];
            
            NSData* contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSXMLParser* parser = [[NSXMLParser alloc] initWithData:contentData];
            parser.delegate = self;
            [parser parse];
        }
    }
    return self;
}

#pragma mark - Properties

- (NSDictionary*)properties
{
    return self.elementValues;
}

- (NSDictionary*)params
{
    return self.campaignParams;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [self.elementStack addObject:elementName];
    
    self.elementAttributes = attributeDict;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    id key = [self.elementStack lastObject];
    
    if ((key != nil) && (self.stringBuffer != nil))
    {
        if ([@"param" isEqualToString:key])
        {
            key = [self.elementAttributes valueForKey:@"name"];
            [self.campaignParams setValue:self.stringBuffer forKey:key];
        }
        else
        {
            [self.elementValues setValue:self.stringBuffer forKey:key];
        }
        
        self.stringBuffer = nil;
    }

    [self.elementStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    id key = [self.elementStack lastObject];
    if (key == nil)
        return;
    
    if (self.stringBuffer == nil)
        self.stringBuffer = [[NSMutableString alloc] initWithCapacity:1024];
    
    [self.stringBuffer appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    id key = [self.elementStack lastObject];
    if (key == nil)
        return;
    
    NSString* string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    
    [self.elementValues setValue:string forKey:key];
}

@end
