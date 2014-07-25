//
//  MMLineDrawingView.h
//  WordFindTest
//
//  Created by Joe on 6/6/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMLine : NSObject

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic, strong) UIColor *color;

+ (MMLine*)lineFromPoint:(CGPoint)argStartPoint toPoint:(CGPoint)argEndPoint withColor:(UIColor*)argColor;

@end

@interface MMLineDrawingView : UIView

@property (nonatomic) CGFloat temporaryLineWidth;
@property (nonatomic) CGFloat permanentLineWidth;

- (NSArray*)permanentLines;
- (void)addPermanentLine:(MMLine*)argLine;
- (void)removePermanentLine:(MMLine*)argLine;

- (MMLine*)temporaryLine;
- (void)setTemporaryLine:(MMLine*)argLine;

- (void)clearAllLines;

@end
