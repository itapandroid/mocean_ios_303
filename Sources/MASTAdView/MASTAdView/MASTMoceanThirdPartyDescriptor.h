//
//  MASTAdView
//
//  Created on 9/21/12.
//  Copyright (c) 2011, 2012 Mocean Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MASTMoceanThirdPartyDescriptor : NSObject <NSXMLParserDelegate>

- (id)initWithClientSideExternalCampaign:(NSString*)clientSideExternalCampaignContent;

@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSDictionary* params;

@end
