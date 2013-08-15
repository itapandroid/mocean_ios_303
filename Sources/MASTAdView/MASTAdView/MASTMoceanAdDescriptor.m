//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import "MASTMoceanAdDescriptor.h"


@interface MASTMoceanAdDescriptor()
@property (nonatomic, strong) NSDictionary* attributes;
@property (nonatomic, assign) id<NSXMLParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableArray* elementStack;
@property (nonatomic, strong) NSMutableDictionary* elementValues;
@property (nonatomic, strong) NSMutableString* stringBuffer;
@end

@implementation MASTMoceanAdDescriptor

@synthesize attributes, parentDelegate, elementStack, elementValues, stringBuffer;

+ (id)descriptorWithRichMediaContent:(NSString*)content
{
    MASTMoceanAdDescriptor* descriptor = [[MASTMoceanAdDescriptor alloc] initWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"richmedia", @"type", nil]];
    
    [[descriptor elementValues] setValue:content forKey:@"content"];
    
    return descriptor;
}

- (id)initWithAttributes:(NSDictionary*)a
{
    self = [super init];
    if (self)
    {
        self.attributes = a;
        self.elementStack = [NSMutableArray new];
        self.elementValues = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithParser:(NSXMLParser*)parser attributes:(NSDictionary*)a
{
    self = [self initWithAttributes:a];
    if (self)
    {
        self.parentDelegate = parser.delegate;
        parser.delegate = self;
    }
    return self;
}

- (NSString*)type
{
    return [self.attributes valueForKey:@"type"];
}

- (NSString*)url
{
    return [self.elementValues valueForKey:@"url"];
}

- (NSString*)text
{
    return [self.elementValues valueForKey:@"text"];
}

- (NSString*)img
{
    return [self.elementValues valueForKey:@"img"];
}

- (NSString*)content
{
    return [self.elementValues valueForKey:@"content"];
}

- (NSString*)track
{
    return [self.elementValues valueForKey:@"track"];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [self.elementStack addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    id key = [self.elementStack lastObject];
    if ((key != nil) && (self.stringBuffer != nil))
    {
        [self.elementValues setValue:self.stringBuffer forKey:key];
        self.stringBuffer = nil;
    }
    
    if ([@"ad" isEqualToString:elementName])
    {
        parser.delegate = self.parentDelegate;
        
        if ([parser.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)])
            [parser.delegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
        
        self.parentDelegate = nil;
        self.elementStack = nil;
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

#pragma mark -

- (NSString*)description
{
    return [NSString stringWithFormat:@"type:%@, url:%@", [self type], [self url]];
}

@end
