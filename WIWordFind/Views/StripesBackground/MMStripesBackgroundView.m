//
//  MMStripesBackgroundView.m
//  BackgroundAndButtonDesignTestProject
//
//  Created by Joe on 4/10/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMStripesBackgroundView.h"

@interface MMStripesBackgroundView ()
{
    CGFloat stripeAngle_mm;
    NSArray *stripeColors_mm;
    CGFloat stripeWidth_mm;
}


@end

@implementation MMStripesBackgroundView

- (id)init
{
    if ((self = [super init]))
    {
        stripeColors_mm = @[[UIColor whiteColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)argRect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(currentContext, 1.25 * stripeWidth_mm);
    
    CGPoint stripeStartPoint = CGPointZero;
    CGPoint stripeEndPoint = CGPointZero;
    
    NSUInteger stripeColorIndex = 0;
//    NSLog(@"Sine of angle: %f", sinf(stripeAngle_mm));
//    NSLog(@"Cosine of angle: %f", cosf(stripeAngle_mm));
    
    // Start by defining an enum with 4 quadrant values
    // Calculate the quadrant of the current angle once
    // Create individual methods that return values and boundaries in case statements for the quadrant values
    // Then refactor this into a single method
    
    
    if (fabsf(cosf(stripeAngle_mm)) >= fabsf(sinf(stripeAngle_mm)))
    {
        CGFloat yIncrement = fabsf((stripeWidth_mm) / cosf(stripeAngle_mm));
        CGFloat yOffset = fabsf((stripeWidth_mm + self.bounds.size.width) * tanf(stripeAngle_mm));
        
        if ((cosf(stripeAngle_mm) * sinf(stripeAngle_mm)) >= 0)
        {
            stripeStartPoint = CGPointMake(-stripeWidth_mm, -stripeWidth_mm);
            stripeEndPoint = CGPointMake((self.bounds.size.width + stripeWidth_mm), stripeStartPoint.y - yOffset);
            
            while (stripeEndPoint.y < self.bounds.size.height + stripeWidth_mm)
            {
                CGColorRef stripeColor = [[stripeColors_mm objectAtIndex:stripeColorIndex] CGColor];
                [self drawLineInContext:currentContext fromPoint:stripeStartPoint toPoint:stripeEndPoint withColor:stripeColor];

                stripeStartPoint = CGPointMake(-stripeWidth_mm, stripeStartPoint.y + yIncrement);
                stripeEndPoint = CGPointMake((self.bounds.size.width + stripeWidth_mm), stripeStartPoint.y - yOffset);
                
                stripeColorIndex++;
                if (stripeColorIndex >= [stripeColors_mm count])
                    stripeColorIndex = 0;
            }
        }
        else
        {
            stripeEndPoint = CGPointMake((self.bounds.size.width + stripeWidth_mm), -stripeWidth_mm);
            stripeStartPoint = CGPointMake(-stripeWidth_mm, stripeEndPoint.y - yOffset);
            
            while (stripeStartPoint.y < (self.bounds.size.height + stripeWidth_mm))
            {
                CGColorRef stripeColor = [[stripeColors_mm objectAtIndex:stripeColorIndex] CGColor];
                [self drawLineInContext:currentContext fromPoint:stripeStartPoint toPoint:stripeEndPoint withColor:stripeColor];
                
                stripeStartPoint = CGPointMake(-stripeWidth_mm, stripeStartPoint.y + yIncrement);
                stripeEndPoint = CGPointMake((self.bounds.size.width + stripeWidth_mm), stripeStartPoint.y + yOffset);
                
                stripeColorIndex++;
                if (stripeColorIndex >= [stripeColors_mm count])
                    stripeColorIndex = 0;
            }
        }
    }
    else
    {
        CGFloat xIncrement = fabsf((stripeWidth_mm) / sinf(stripeAngle_mm));
        CGFloat xOffset = fabsf((stripeWidth_mm + self.bounds.size.height) / tanf(stripeAngle_mm));
        
        if (cosf(stripeAngle_mm) * sinf(stripeAngle_mm) >= 0)
        {
            stripeStartPoint = CGPointMake(-stripeWidth_mm, -stripeWidth_mm);
            stripeEndPoint = CGPointMake(stripeStartPoint.x - xOffset, (self.bounds.size.height + stripeWidth_mm));
            
            while (stripeEndPoint.x < self.bounds.size.width + stripeWidth_mm)
            {
                CGColorRef stripeColor = [[stripeColors_mm objectAtIndex:stripeColorIndex] CGColor];
                [self drawLineInContext:currentContext fromPoint:stripeStartPoint toPoint:stripeEndPoint withColor:stripeColor];
                
                stripeStartPoint = CGPointMake(stripeStartPoint.x + xIncrement, -stripeWidth_mm);
                stripeEndPoint = CGPointMake(stripeStartPoint.x - xOffset, (self.bounds.size.height + stripeWidth_mm));
                
                stripeColorIndex++;
                if (stripeColorIndex >= [stripeColors_mm count])
                    stripeColorIndex = 0;
            }
        }
        else
        {
            stripeEndPoint = CGPointMake(-stripeWidth_mm, (self.bounds.size.height + stripeWidth_mm));
            stripeStartPoint = CGPointMake(stripeEndPoint.x - xOffset, -stripeWidth_mm);
            
            while (stripeStartPoint.x < self.bounds.size.width + stripeWidth_mm)
            {
                CGColorRef stripeColor = [[stripeColors_mm objectAtIndex:stripeColorIndex] CGColor];
                [self drawLineInContext:currentContext fromPoint:stripeStartPoint toPoint:stripeEndPoint withColor:stripeColor];
                
                stripeStartPoint = CGPointMake(stripeStartPoint.x + xIncrement, -stripeWidth_mm);
                stripeEndPoint = CGPointMake(stripeStartPoint.x + xOffset, (self.bounds.size.height + stripeWidth_mm));
                
                stripeColorIndex++;
                if (stripeColorIndex >= [stripeColors_mm count])
                    stripeColorIndex = 0;
            }
            // StartPoint is determined by end point being at 0
            
            
            // Loop by incrementing start point until it is past view height
        }
    }
}

- (void)drawLineInContext:(CGContextRef)argContext fromPoint:(CGPoint)argStartPoint toPoint:(CGPoint)argEndPoint withColor:(CGColorRef)argColor
{
    CGContextSetStrokeColorWithColor(argContext, argColor);
    CGContextMoveToPoint(argContext, argStartPoint.x, argStartPoint.y);
    CGContextAddLineToPoint(argContext, argEndPoint.x, argEndPoint.y);
    CGContextStrokePath(argContext);
}

#pragma mark - Stripe Angle

- (CGFloat)stripeAngle
{
    return stripeAngle_mm;
}

- (void)setStripeAngle:(CGFloat)argStripeAngle
{
    stripeAngle_mm = argStripeAngle;
    [self setNeedsDisplay];
}

#pragma mark - Stripe Colors

- (NSArray*)stripeColors
{
    return stripeColors_mm;
}

- (void)setStripeColors:(NSArray*)argStripeColors
{
    NSAssert([argStripeColors count] > 0, @"No stripe colors to set");
    stripeColors_mm = argStripeColors;
    [self setNeedsDisplay];
}

#pragma mark - Stripe Width

- (CGFloat)stripeWidth
{
    return stripeWidth_mm;
}

- (void)setStripeWidth:(CGFloat)argStripeWidth
{
    stripeWidth_mm = argStripeWidth;
    [self setNeedsDisplay];
}

@end
