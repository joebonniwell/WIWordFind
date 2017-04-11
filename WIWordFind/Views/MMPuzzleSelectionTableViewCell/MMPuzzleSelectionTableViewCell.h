//
//  MMPuzzleSelectionTableViewCell.h
//  WIWordFind
//
//  Created by Joe on 7/27/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPuzzleSelectionTableViewCell : UITableViewCell

// Puzzle preview image
@property (nonatomic, weak) IBOutlet UILabel *puzzleNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *puzzleTaglineLabel;
// Puzzle status view

- (UIView*)cellBackgroundView;

@end
