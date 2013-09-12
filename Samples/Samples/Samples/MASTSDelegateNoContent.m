//
//  MASTSDelegateNoContent.m
//  Samples
//
//  Created on 1/14/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "MASTSDelegateNoContent.h"

@interface MASTSDelegateNoContent ()

@end

@implementation MASTSDelegateNoContent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger site = 19829;
    NSInteger zone = 158514;
    
    self.adView.site = site;
    self.adView.zone = zone;
}

@end
