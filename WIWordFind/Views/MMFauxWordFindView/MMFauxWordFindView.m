//
//  MMFauxWordFindView.m
//  WIWordFind
//
//  Created by Joe on 7/30/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMFauxWordFindView.h"

@interface MMFauxWordFindView ()
{
    int rows_mm;
    int columns_mm;
}

@end

@implementation MMFauxWordFindView

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)argFrame
{
    if ((self = [super initWithFrame:argFrame]))
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    [self.layer setCornerRadius:4.0f];
    [self setClipsToBounds:YES];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.97f alpha:1.0f]];
    
    [self applyDefaults];
    [self layoutWordFind];
}

- (void)applyDefaults
{
    rows_mm = 4;
    columns_mm = 4;
}

- (void)layoutWordFind
{
    NSArray *allCharacters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    // Construct the letter labels
    
    CGFloat horizontalOffset = 4.0f;
    CGFloat verticalOffset = 4.0f;
    CGFloat labelWidth = (self.bounds.size.width - (2.0f * horizontalOffset)) / columns_mm;
    CGFloat labelHeight = (self.bounds.size.height - (2.0f *verticalOffset)) / rows_mm;
    
    for (int row = 0; row < rows_mm; row++)
    {
        for (int column = 0; column < columns_mm; column++)
        {
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                        horizontalOffset + (column * labelWidth),
                                                                        verticalOffset + (row * labelHeight),
                                                                        labelWidth,
                                                                        labelHeight
                                                                        )];
            [self addSubview:aLabel];
            
            [aLabel setText:[allCharacters objectAtIndex:arc4random_uniform([allCharacters count])]];
            [aLabel setTextAlignment:NSTextAlignmentCenter];
            [aLabel setTextColor:[UIColor colorWithWhite:0.6 alpha:1.0f]];
            [aLabel setFont:[UIFont systemFontOfSize:labelHeight - 2.0f]];
            // Create a label
            
            // Add a random character
            
            // Add label to view
        }
    }
}

@end
