//
//  MMLineDrawingView.m
//  WordFindTest
//
//  Created by Joe on 6/6/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMLineDrawingView.h"

@interface MMLineDrawingView ()
{
    NSMutableArray *permanentLines_mm;
    MMLine *temporaryLine_mm;
}

@end

@implementation MMLineDrawingView

- (id)init
{
    if ((self = [super init]))
    {
//        [self clearLine];
        permanentLines_mm = [NSMutableArray array];
    }
    return self;
}

- (id)initWithFrame:(CGRect)argFrame
{
    if ((self = [super initWithFrame:argFrame]))
    {
//        [self clearLine];
        permanentLines_mm = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)argRect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (MMLine *aPermanentLine in permanentLines_mm)
    {
        CGContextSetStrokeColorWithColor(context, [aPermanentLine.color CGColor]);
        CGContextMoveToPoint(context, aPermanentLine.startPoint.x, aPermanentLine.startPoint.y);
        CGContextAddLineToPoint(context, aPermanentLine.endPoint.x, aPermanentLine.endPoint.y);
        CGContextStrokePath(context);
    }
    
    if (temporaryLine_mm)
    {
        CGContextSetStrokeColorWithColor(context, [temporaryLine_mm.color CGColor]);
        CGContextMoveToPoint(context, temporaryLine_mm.startPoint.x, temporaryLine_mm.startPoint.y);
        CGContextAddLineToPoint(context, temporaryLine_mm.endPoint.x, temporaryLine_mm.endPoint.y);
        CGContextStrokePath(context);
    }
}

//- (void)drawLineFromPoint:(CGPoint)argStartingPoint toPoint:(CGPoint)argEndingPoint
//{
//    startPoint_mm = argStartingPoint;
//    endPoint_mm = argEndingPoint;
//    [self setNeedsDisplay];
//}

- (void)clearAllLines
{
    [permanentLines_mm removeAllObjects];
    temporaryLine_mm = nil;
    
    [self setNeedsDisplay];
}

- (void)addPermanentLine:(MMLine*)argLine
{
    [permanentLines_mm addObject:argLine];
    [self setNeedsDisplay];
}

- (void)removePermanentLine:(MMLine*)argLine
{
    [permanentLines_mm removeObject:argLine];
    [self setNeedsDisplay];
}

- (MMLine*)temporaryLine
{
    return temporaryLine_mm;
}

- (void)setTemporaryLine:(MMLine*)argLine
{
    temporaryLine_mm = argLine;
    [self setNeedsDisplay];
}

@end

#pragma mark - MMLine

@implementation MMLine

+ (MMLine*)lineFromPoint:(CGPoint)argStartPoint toPoint:(CGPoint)argEndPoint withColor:(UIColor*)argColor
{
    MMLine *aLine = [[MMLine alloc] init];
    [aLine setStartPoint:argStartPoint];
    [aLine setEndPoint:argEndPoint];
    [aLine setColor:argColor];
    return aLine;
}

@end