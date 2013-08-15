//
//  UIImageView+MASTAdView.m
//  MASTAdView
//
//  Created on 10/22/12.
//  Copyright (c) 2012 Mocean Mobile. All rights reserved.
//

#import "UIImageView+MASTAdView.h"
#import <objc/runtime.h>

static const char* DelayIndexKey = "DelayIndexKey";
static const char* DelayImagesKey = "DelayImagesKey";
static const char* DelayIntervalsKey = "DelayIntervalsKey";
static const char* DelayTimerKey = "DelayTimerKey";

@interface UIImageView()
@property (nonatomic, assign) NSInteger delayIndex;
@property (nonatomic, strong) NSArray* delayImages;
@property (nonatomic, strong) NSArray* delayIntervals;
@property (nonatomic, strong) NSTimer* delayTimer;
@end

@implementation UIImageView (MASTAdView)

- (NSInteger)delayIndex
{
    id obj = objc_getAssociatedObject(self, DelayIndexKey);
    return [obj integerValue];
}

- (void)setDelayIndex:(NSInteger)delayIndex
{
    objc_setAssociatedObject(self, DelayIndexKey, [NSNumber numberWithInteger:delayIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)delayImages
{
    id obj = objc_getAssociatedObject(self, DelayImagesKey);
    return obj;
}

- (void)setDelayImages:(NSArray *)delayImages
{
    objc_setAssociatedObject(self, DelayImagesKey, delayImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)delayIntervals
{
    id obj = objc_getAssociatedObject(self, DelayIntervalsKey);
    return obj;
}

- (void)setDelayIntervals:(NSArray *)delayIntervals
{
    objc_setAssociatedObject(self, DelayIntervalsKey, delayIntervals, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)delayTimer
{
    id obj = objc_getAssociatedObject(self, DelayTimerKey);
    return obj;
}

- (void)setDelayTimer:(NSTimer *)delayTimer
{
    objc_setAssociatedObject(self, DelayTimerKey, delayTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImages:(NSArray *)images withDurations:(NSArray *)durations
{
    [self.delayTimer invalidate];
    
    self.delayImages = images;
    self.delayIntervals = durations;
    self.delayIndex = 0;
    
    [self nextDelayImage];
    
    if (([self.delayImages count] == 0) || ([self.delayIntervals count] == 0))
        self.image = nil;
}

- (void)nextDelayImage
{
    if (([self.delayImages count] == 0) || ([self.delayIntervals count] == 0))
        return;
    
    UIImage* image = [self.delayImages objectAtIndex:self.delayIndex];
    NSTimeInterval interval = [[self.delayIntervals objectAtIndex:self.delayIndex] floatValue];
    
    self.image = image;
    
    ++self.delayIndex;
    if (self.delayIndex == [self.delayImages count])
        self.delayIndex = 0;
    
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(nextDelayImage)
                                   userInfo:nil
                                    repeats:NO];
}

@end
