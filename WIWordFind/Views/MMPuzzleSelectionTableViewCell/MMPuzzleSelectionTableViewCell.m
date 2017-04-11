//
//  MMPuzzleSelectionTableViewCell.m
//  WIWordFind
//
//  Created by Joe on 7/27/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMPuzzleSelectionTableViewCell.h"

@interface MMPuzzleSelectionTableViewCell ()
{
    BOOL initialConstraintsAdded_mm;
}

@property (nonatomic, weak) IBOutlet UIView *cellBackgroundView;

@end

@implementation MMPuzzleSelectionTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.cellBackgroundView.layer setCornerRadius:16.0f];
    [self.cellBackgroundView setClipsToBounds:YES];
    
    [self.layer setCornerRadius:24.0f];
    [self setClipsToBounds:YES];    
}

@end
