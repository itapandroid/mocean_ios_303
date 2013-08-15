//
//  MASTSDelegate.h
//  AdMobileSamples
//
//  Created on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSSimple.h"

@interface MASTSDelegate : MASTSSimple <MASTAdViewDelegate>

@property (nonatomic, retain) UITextView* textView;

- (void)writeEntry:(NSString*)entry;

@end
