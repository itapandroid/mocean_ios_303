//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//


#import "NSDictionary+MASTAdView.h"

@implementation NSDictionary (MASTAdView)

+ (id)dictionaryWithJavaScriptObject:(NSString*)javaScriptObject
{
    return [self parseJSONString:javaScriptObject];
}

+ (id)parseJSONString:(NSString*)string
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    
    id value = [self parseJSONScanner:scanner];
    
    return value;
}

+ (id)parseJSONScanner:(NSScanner*)scanner
{
    id value = nil;
    double* doubleValue = nil;
    
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
        
    if ([scanner scanString:@"\"" intoString:NULL])
    {
        value = [self parseJSONStringValue:scanner];
    }
    else if ([scanner scanString:@"{" intoString:NULL])
    {
        NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
        
        while (true)
        {
            [scanner scanString:@"," intoString:NULL];
            
            [scanner scanString:@"\"" intoString:NULL];
            NSString* key = [self parseJSONStringValue:scanner];
            [scanner scanString:@":" intoString:NULL];
            
            id object = [self parseJSONScanner:scanner];
            
            if (([key length] > 0) && (object != nil))
            {
                [dictionary setObject:object forKey:key];
            }
            
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
            
            if (([scanner.string characterAtIndex:scanner.scanLocation] == '}'))
            {
                break;
            }
        }
        
        [scanner scanString:@"}" intoString:NULL];
        
        value = dictionary;
    }
    else if ([scanner scanString:@"[" intoString:NULL])
    {
        while (true)
        {
            [scanner scanString:@"," intoString:NULL];
            
            // TODO: value = parseArray

            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
            if (([scanner.string characterAtIndex:scanner.scanLocation] == ']'))
            {
                break;
            }
        }
    }
    else if ([scanner scanString:@"true" intoString:NULL])
    {
        value = [NSNumber numberWithBool:YES];
    }
    else if ([scanner scanString:@"false" intoString:NULL])
    {
        value = [NSNumber numberWithBool:NO];
    }
    else if ([scanner scanString:@"null" intoString:NULL])
    {
        value = [NSNull null];
    }
    else if ([scanner scanDouble:doubleValue])
    {
        if (doubleValue != nil)
            value = [NSNumber numberWithDouble:*doubleValue];
    }
    
    return value;
}

// assumes scanner is parked on a double quote
+ (NSString*)parseJSONStringValue:(NSScanner*)scanner
{
    NSMutableString* string = [NSMutableString string];
    
    NSString* stringValue = nil;
    while ([scanner scanUpToString:@"\"" intoString:&stringValue])
    {
        [string appendString:stringValue];
        
        // a trailing \ indicates the quote is escaped
        if ([stringValue hasSuffix:@"\\"] == NO)
            break;
        
        // replaces \" with " (unescapes the double quote)
        [string replaceCharactersInRange:NSMakeRange(string.length - 1, 1) withString:@"\""];
        
        // reads past the escaped quote
        [scanner scanString:@"\\\"" intoString:NULL];
    }
    
    // finally reads past the ending double qoute
    [scanner scanString:@"\"" intoString:NULL];

    return string;
}

@end
