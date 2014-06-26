//
//  MMStripesBackgroundView.h
//  BackgroundAndButtonDesignTestProject
//
//  Created by Joe on 4/10/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMStripesBackgroundView : UIView

- (CGFloat)stripeAngle;
- (void)setStripeAngle:(CGFloat)argStripeAngle;

- (NSArray*)stripeColors;
- (void)setStripeColors:(NSArray*)argStripeColors;

- (CGFloat)stripeWidth;
- (void)setStripeWidth:(CGFloat)argStripeWidth;

@end
