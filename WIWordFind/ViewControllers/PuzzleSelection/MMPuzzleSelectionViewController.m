//
//  MMPuzzleSelectionViewController.m
//  WIWordFind
//
//  Created by Joe on 7/12/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMPuzzleSelectionViewController.h"

#import "MMWordFindPuzzle.h"
#import "MMWordFindViewController.h"
#import "MMStripesBackgroundView.h"
#import "MMAppDelegate.h"
#import "MMPuzzleSelectionTableViewCell.h"

#define ShowPuzzle @"ShowPuzzle"

#define PuzzleCellIdentifier @"PuzzleCellIdentifier"

@interface MMPuzzleSelectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *allPuzzles;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MMStripesBackgroundView *stripesBackgroundView;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@property (nonatomic, weak) IBOutlet UIButton *randomPuzzleButton;

@end

@implementation MMPuzzleSelectionViewController

// Need to change the cells to be shaped nicer...
// Need to change the layout of the cells to have some sort of graphic
// Need to change the buttons

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.stripesBackgroundView setStripeAngle:(M_PI / 4.0f)];
    [self.stripesBackgroundView setStripeColors:@[
                                                  [UIColor colorWithRed:0.478f green:0.667f blue:0.745f alpha:1.0f],
                                                  [UIColor colorWithRed:0.424f green:0.620f blue:0.702f alpha:1.0f]
                                                  ]];
    
    [self.stripesBackgroundView setStripeWidth:40.0f];
    
    [self setAllPuzzles:[NSMutableArray array]];
    [self loadPuzzlesFromDisk];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView reloadData];
    
    [self.homeButton.layer setCornerRadius:16.0f];
    [self.homeButton setClipsToBounds:YES];
    
    [self.randomPuzzleButton.layer setCornerRadius:16.0f];
    [self.randomPuzzleButton setClipsToBounds:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)argSegue sender:(id)argSender
{
    if ([[argSegue identifier] isEqualToString:ShowPuzzle])
    {
        [(MMWordFindViewController*)[argSegue destinationViewController] setCurrentPuzzle:argSender];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Other Methods

- (void)loadPuzzlesFromDisk
{
    [self.allPuzzles removeAllObjects];
    NSArray *puzzleURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[APP_DELEGATE puzzleDirectoryURL] includingPropertiesForKeys:nil options:0 error:nil];
    NSLog(@"Puzzles to load: %@", puzzleURLs);
    for (NSURL *aPuzzleURL in puzzleURLs)
    {
        NSData *aPuzzleData = [NSData dataWithContentsOfURL:aPuzzleURL];
        if ([NSJSONSerialization isValidJSONObject:aPuzzleData])
        {
            NSLog(@"Valid JSON");
        }
        else
        {
            NSLog(@"Invalid JSON");
        }
        MMWordFindPuzzle *aPuzzle = [MMWordFindPuzzle puzzleFromJSON:aPuzzleData];
        [self.allPuzzles addObject:aPuzzle];
    }
}

#pragma mark - Button Actions

- (IBAction)menuButtonTapped:(id)argSender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)randomPuzzleButtonTapped:(id)argSender
{
    NSLog(@"TODO: Choose a random puzzle and advance");
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)argTableView numberOfRowsInSection:(NSInteger)argSection
{
    return [self.allPuzzles count];
}

- (UITableViewCell *)tableView:(UITableView *)argTableView cellForRowAtIndexPath:(NSIndexPath *)argIndexPath
{
    MMPuzzleSelectionTableViewCell *cellForRow = [argTableView dequeueReusableCellWithIdentifier:PuzzleCellIdentifier forIndexPath:argIndexPath];
    
    MMWordFindPuzzle *puzzleForRow = [self.allPuzzles objectAtIndex:argIndexPath.row];
    
    [cellForRow.puzzleNameLabel setText:[puzzleForRow puzzleName]];
    // Set SubTitle
    
    return cellForRow;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)argTableView didSelectRowAtIndexPath:(NSIndexPath *)argIndexPath
{
    [argTableView deselectRowAtIndexPath:argIndexPath animated:YES];
    
    MMWordFindPuzzle *selectedPuzzle = [self.allPuzzles objectAtIndex:argIndexPath.row];
    
    [self performSegueWithIdentifier:ShowPuzzle sender:selectedPuzzle];
}

//#pragma mark - UIScrollViewDelegate Methods
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    // Fades out top and bottom cells in table view as they leave the screen
//    NSArray *visibleCells = [self.tableView visibleCells];
//    
//    if (visibleCells != nil  &&  [visibleCells count] != 0) {       // Don't do anything for empty table view
//        
//        /* Get top and bottom cells */
//        UITableViewCell *topCell = [visibleCells objectAtIndex:0];
//        UITableViewCell *bottomCell = [visibleCells lastObject];
//        
//        /* Make sure other cells stay opaque */
//        // Avoids issues with skipped method calls during rapid scrolling
//        for (UITableViewCell *cell in visibleCells) {
//            cell.contentView.alpha = 1.0;
//        }
//        
//        /* Set necessary constants */
//        NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 To allow for typical separator line height
//        NSInteger tableViewTopPosition = self.tableView.frame.origin.y;
//        NSInteger tableViewBottomPosition = self.tableView.frame.origin.y + self.tableView.frame.size.height;
//        
//        /* Get content offset to set opacity */
//        CGRect topCellPositionInTableView = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:topCell]];
//        CGRect bottomCellPositionInTableView = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:bottomCell]];
//        CGFloat topCellPosition = [self.tableView convertRect:topCellPositionInTableView toView:[self.tableView superview]].origin.y;
//        CGFloat bottomCellPosition = ([self.tableView convertRect:bottomCellPositionInTableView toView:[self.tableView superview]].origin.y + cellHeight);
//        
//        /* Set opacity based on amount of cell that is outside of view */
//        CGFloat modifier = 2.0;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
//                                     2.0 for fully transparent when the cell is half off the screen, etc) */
//        CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
//        CGFloat bottomCellOpacity = (1.0f - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier);
//        
//        /* Set cell opacity */
//        if (topCell) {
//            topCell.contentView.alpha = topCellOpacity;
//        }
//        if (bottomCell) {
//            bottomCell.contentView.alpha = bottomCellOpacity;
//        }
//    }
//}

@end
