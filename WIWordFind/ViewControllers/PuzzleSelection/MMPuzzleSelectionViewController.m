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

#import "MMAppDelegate.h"

#define ShowPuzzle @"ShowPuzzle"

#define PuzzleCellIdentifier @"PuzzleCellIdentifier"

@interface MMPuzzleSelectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *allPuzzles;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MMPuzzleSelectionViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAllPuzzles:[NSMutableArray array]];
    [self loadPuzzlesFromDisk];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView reloadData];
    
    
    // Load up all of the puzzles in the puzzle directory
}

- (void)prepareForSegue:(UIStoryboardSegue *)argSegue sender:(id)argSender
{
    if ([[argSegue identifier] isEqualToString:ShowPuzzle])
    {
        [(MMWordFindViewController*)[argSegue destinationViewController] setCurrentPuzzle:argSender];
    }
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
    UITableViewCell *cellForRow = [argTableView dequeueReusableCellWithIdentifier:PuzzleCellIdentifier forIndexPath:argIndexPath];
    
    MMWordFindPuzzle *puzzleForRow = [self.allPuzzles objectAtIndex:argIndexPath.row];
    
    [cellForRow.textLabel setText:[puzzleForRow puzzleName]];
    // Configure for puzzle
    
    return cellForRow;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)argTableView didSelectRowAtIndexPath:(NSIndexPath *)argIndexPath
{
    [argTableView deselectRowAtIndexPath:argIndexPath animated:YES];
    
    MMWordFindPuzzle *selectedPuzzle = [self.allPuzzles objectAtIndex:argIndexPath.row];
    
    [self performSegueWithIdentifier:ShowPuzzle sender:selectedPuzzle];
}

@end
