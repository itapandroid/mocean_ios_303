//
//  UINavigationController+Rotation.m
//  Samples
//
//  Created on 1/8/13.
//  Copyright (c) 2013 mOcean Mobile. All rights reserved.
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)

- (BOOL)shouldAutorotate
{
    BOOL result = self.topViewController.shouldAutorotate;
    return result;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger result = self.topViewController.supportedInterfaceOrientations;
    return result;
}

@end
