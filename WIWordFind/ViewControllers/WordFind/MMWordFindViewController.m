//
//  MMViewController.m
//  WordFindTest
//
//  Created by Joe on 6/6/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMWordFindViewController.h"
#import "MMLineDrawingView.h"
#import "MMStripesBackgroundView.h"
#import <iAd/iAd.h>

#import "MMCoordinate.h"
#import "MMPosition.h"
#import "MMWordGrid.h"
#import "MMWordFindPuzzle.h"

#import "MMAppDelegate.h"

#define HintBlinkPeriod 0.6f

@interface MMWordFindViewController () <UIAlertViewDelegate, ADBannerViewDelegate>
{
    MMWordGrid *wordGrid;
    NSMutableArray *viewArray;
    
    CGFloat labelWidth;
    CGFloat labelHeight;
    CGRect overallLetterRect;
    
    BOOL isTracking;
    
    MMCoordinate *currentStartingCoordinate;
    CGPoint currentEndPoint;
    MMCoordinate *currentEndingCoordinate;
    
    NSMutableSet *permanentSelectionCoordinates_mm;
    NSMutableSet *activeHintCoordinates_mm;
    
    UIColor *activeLineColor_mm;
    UIColor *permanentLineColor_mm;
    
    NSMutableArray *wordLabels_mm;
    
    BOOL hintIsOn_mm;
    NSTimeInterval lastHintTimeStamp_mm;
}

@property (nonatomic, strong) MMLineDrawingView *lineDrawingView;
@property (nonatomic, strong) UILabel *selectionLabel;

@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) NSMutableArray *foundWords;

@property (nonatomic, weak) IBOutlet MMStripesBackgroundView *stripesBackgroundView;

@property (nonatomic, weak) IBOutlet ADBannerView *adBannerView;

@property (nonatomic, strong) NSTimer *hintTimer;

@end

@implementation MMWordFindViewController

// TODO: Add a more dynamic layout depending on screen size and orientation

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    permanentLineColor_mm = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:0.35f];
    activeLineColor_mm = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.65f];

    permanentSelectionCoordinates_mm = [NSMutableSet set];
    activeHintCoordinates_mm = [NSMutableSet set];
    [self setFoundWords:[NSMutableArray array]];
    
    // Word Grid Generation
    wordGrid = [[MMWordGrid alloc] initWithRows:self.currentPuzzle.rows columns:self.currentPuzzle.columns];
    [wordGrid configureWithPuzzle:self.currentPuzzle];
    [self setWords:self.currentPuzzle.matchStrings];
    
    [self configureStripeBackground];
    [self configurePuzzleBackgroundView];
    [self configurePuzzleLetterLabels];
    [self configureLineDrawingView];
    [self configureSelectionLabel];
    [self configureDisplayStringLabels];
    [self configureHintButton];
    
    [self updateGrid];
    [self updateLetters];
    
    [self setHintTimer:[NSTimer scheduledTimerWithTimeInterval:(0.5f * HintBlinkPeriod) target:self selector:@selector(updateHints) userInfo:nil repeats:YES]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [self.hintTimer invalidate];
}

#pragma mark - View Configuration Methods

- (void)configureStripeBackground
{
    [self.stripesBackgroundView setStripeAngle:(M_PI / 4.0f)];
    [self.stripesBackgroundView setStripeColors:@[
                                                  [UIColor colorWithRed:0.478f green:0.667f blue:0.745f alpha:1.0f],
                                                  [UIColor colorWithRed:0.424f green:0.620f blue:0.702f alpha:1.0f]
                                                  ]];
    
    [self.stripesBackgroundView setStripeWidth:40.0f]; // Active stripe width and permanent stripe width
}

- (void)configurePuzzleBackgroundView
{
    CGFloat heightOffset = (self.view.bounds.size.height - 320.0f) * 0.5f;
    UIView *puzzleBackingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, heightOffset, 320.0f, 320.0f)];
    [puzzleBackingView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [self.view addSubview:puzzleBackingView];
    [puzzleBackingView.layer setCornerRadius:10.0f];
    [puzzleBackingView setClipsToBounds:YES];
}

- (void)configurePuzzleLetterLabels
{
    CGFloat heightOffset = (self.view.bounds.size.height - 320.0f) * 0.5f;
    // Puzzle Letter Labels
    labelWidth = 320.0f / (1.0f * self.currentPuzzle.rows);
    labelHeight = 320.0f / (1.0f * self.currentPuzzle.columns);
    overallLetterRect = CGRectMake(0.0f, heightOffset, self.currentPuzzle.columns * labelWidth, self.currentPuzzle.rows * labelHeight);
    
    viewArray = [NSMutableArray array];
    for (int row = 0; row < self.currentPuzzle.rows; row++)
    {
        NSMutableArray *aRowArray = [NSMutableArray array];
        [viewArray addObject:aRowArray];
        for (int column = 0; column < self.currentPuzzle.columns; column++)
        {
            UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth * column), (labelHeight * row) + heightOffset, labelWidth, labelHeight)];
            [letterLabel setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:letterLabel];
            [aRowArray addObject:letterLabel];
        }
    }
}

- (void)configureSelectionLabel
{
    CGFloat heightOffset = (self.view.bounds.size.height - 320.0f) * 0.5f;
    [self setSelectionLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, heightOffset - 30.0f, 320.0f, 30.0f)]];
    [self.selectionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.selectionLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [self.view addSubview:self.selectionLabel];
}

- (void)configureLineDrawingView
{
    CGFloat heightOffset = (self.view.bounds.size.height - 320.0f) * 0.5f;
    [self setLineDrawingView:[[MMLineDrawingView alloc] initWithFrame:CGRectMake(0.0f, heightOffset, 320.0f, 320.0f)]];
    [self.lineDrawingView setTemporaryLineWidth:30.0f];
    [self.lineDrawingView setPermanentLineWidth:18.0f];
    [self.lineDrawingView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.lineDrawingView];
}

- (void)configureDisplayStringLabels
{
    CGFloat columns = 4.0f;
    
    // Display Label Generation
    CGFloat offset = 10.0f;
    CGFloat width = ((self.view.bounds.size.width - (2.0f * offset)) / columns);
    CGFloat height = 16.0f;
    
    wordLabels_mm = [NSMutableArray array];
    for (int aWordLabel = 0; aWordLabel < [self.words count]; aWordLabel++)
    {
        // Layout some labels
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset + (fmodf(aWordLabel, columns) * width), 0.5f * (self.view.bounds.size.height + self.view.bounds.size.width) + (floorf(aWordLabel / columns) * 16.0f), width, height)];
        [wordLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [wordLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:wordLabel];
        [wordLabel setText:[self.words objectAtIndex:aWordLabel]];
        [wordLabels_mm addObject:wordLabel];
    }
}

- (void)configureHintButton
{
    UIButton *hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hintButton setFrame:CGRectMake(0.0f, 40.0f, 100.0f, 40.0f)];
    [hintButton setTitle:@"Hint" forState:UIControlStateNormal];
    [hintButton addTarget:self action:@selector(hintButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hintButton];
}

#pragma mark - Interaction Methods

- (void)hintButtonTapped
{
    // Check for available hints // Where to store these?
//    if ([APP_DELEGATE availableHints] == 0)
//    {
//        // Make offer to player to buy/earn more hints
//        UIAlertView *buyMoreHintsAlertView = [[UIAlertView alloc] initWithTitle:@"Out of Hints" message:@"You are out of hints. Would you like to get more?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes Please", nil];
//        // TODO: Set tag on buy more hints alert view
//        [buyMoreHintsAlertView show];
//        return;
//    }
    
    NSMutableArray *remainingWords = [NSMutableArray arrayWithArray:[self.currentPuzzle matchStrings]];
    [remainingWords removeObjectsInArray:[self foundWords]];
    
    MMCoordinate *hintCoordinate = nil;
    while ([remainingWords count] > 0 && !hintCoordinate)
    {
        NSString *randomRemainingWord = [remainingWords objectAtIndex:arc4random_uniform([remainingWords count])];
        
        NSUInteger randomWordIndex = [[self.currentPuzzle matchStrings] indexOfObject:randomRemainingWord];
        if (randomWordIndex == NSNotFound)
        {
            NSLog(@"Couldn't find random word: %@ in match strings: %@", randomRemainingWord, [self.currentPuzzle matchStrings]);
            return;
        }

        MMPosition *randomWordPosition = [[self.currentPuzzle wordPostions] objectAtIndex:randomWordIndex];
        NSMutableArray *coordinatesForRandomWord = [NSMutableArray arrayWithArray:[randomWordPosition coordinates]];
        
        for (MMCoordinate *anActiveHintCoordinate in activeHintCoordinates_mm)
        {
            [coordinatesForRandomWord removeObject:anActiveHintCoordinate];
        }
        
        if ([coordinatesForRandomWord count])
        {
            // Choose a remaining random coordinate
            hintCoordinate = [coordinatesForRandomWord objectAtIndex:arc4random_uniform([coordinatesForRandomWord count])];
            NSLog(@"Hint for %@ at %@ is %@", randomRemainingWord, randomWordPosition, hintCoordinate);
        }
        else
        {
            // Ineligible word for hint...
            [remainingWords removeObject:randomRemainingWord];
        }
    }

    if (!hintCoordinate)
    {
        // TODO: Show an alert view explaining that there are no more hints available for this puzzle...
        return;
    }

    [self showHintAtCoordinate:hintCoordinate];
    [APP_DELEGATE decrementHints];
}

- (void)regenerate
{
//    // Should clear selection indicator as well
//    [self.foundWords removeAllObjects];
//    [wordGrid clearGrid];
//    [self.lineDrawingView clearAllLines];
//    [permanentSelectionCoordinates_mm removeAllObjects];
//
//    MMWordFindPuzzle *aPuzzle = [MMWordFindPuzzle randomPuzzleWithRows:TOTAL_ROWS columns:TOTAL_COLUMNS matchStrings:self.words];
//    [wordGrid configureWithPuzzle:aPuzzle];
//    
//    [self updateGrid];
//    [self updateLetters];
//    
//    for (UILabel *aWordLabel in wordLabels_mm)
//    {
////        [aWordLabel setText:aWordLabel.attributedText.string];
//        [aWordLabel setAttributedText:[[NSAttributedString alloc] initWithString:aWordLabel.attributedText.string]];
//    }
}

#pragma mark - Hints

- (void)showHintAtCoordinate:(MMCoordinate*)argHintCoordinate
{
    [activeHintCoordinates_mm addObject:argHintCoordinate];
}

- (void)updateHints
{
    NSTimeInterval currentTimeStamp = [[NSDate date] timeIntervalSinceReferenceDate];
    if ((currentTimeStamp - lastHintTimeStamp_mm) >= HintBlinkPeriod)
    {
        hintIsOn_mm = !hintIsOn_mm;
        lastHintTimeStamp_mm = currentTimeStamp;
    }
    
    // Hints
    NSArray *activeHintViews = [self viewsForActiveHints];
    if (hintIsOn_mm)
    {
        [activeHintViews makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor blackColor]];
    }
    else
    {
        [activeHintViews makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor whiteColor]];
    }
    [activeHintViews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet*)argTouches withEvent:(UIEvent*)argEvent
{
    if (!isTracking)
    {
        CGPoint startingPoint = [argTouches.anyObject locationInView:self.view];
        if (CGRectContainsPoint(overallLetterRect, startingPoint))
        {
            isTracking = YES;
            CGPoint updatedStartingPoint = [self.view convertPoint:startingPoint toView:self.lineDrawingView];
            currentStartingCoordinate = [self coordinateNearestToPoint:updatedStartingPoint];
            NSLog(@"Starting tracking at coordinate: %d, %d", currentStartingCoordinate.row, currentStartingCoordinate.column);
            [self updateActiveLineForTouchPoint:startingPoint];
        }
    }
}

- (void)touchesMoved:(NSSet*)argTouches withEvent:(UIEvent*)argEvent
{
    if (isTracking)
    {
        CGPoint updatedPoint = [argTouches.anyObject locationInView:self.view];
        [self updateActiveLineForTouchPoint:updatedPoint];
    }
}

- (void)touchesCancelled:(NSSet*)argTouches withEvent:(UIEvent*)argEvent
{
    CGPoint updatedPoint = [argTouches.anyObject locationInView:self.view];
    [self handleTouchEndEventAtPoint:updatedPoint];
}

- (void)touchesEnded:(NSSet*)argTouches withEvent:(UIEvent*)argEvent
{
    CGPoint updatedPoint = [argTouches.anyObject locationInView:self.view];
    [self handleTouchEndEventAtPoint:updatedPoint];
}

- (void)handleTouchEndEventAtPoint:(CGPoint)argPoint
{
    isTracking = NO;
    NSLog(@"Ending tracking due to touches ended");
    // Would clear the line here normally
    
    [self updateActiveLineForTouchPoint:argPoint];
    
    CGPoint finalPoint = [self.view convertPoint:[self centerPointForCoordinate:currentEndingCoordinate] fromView:self.lineDrawingView];
    [self updateActiveLineForTouchPoint:finalPoint];
    
    
    NSString *selectedString = [self stringForCurrentSelection];
    NSLog(@"Selected string: %@", selectedString);
    for (NSString *aWord in self.words)
    {
        // Could check for reversed string matching as well
        if ([aWord isEqualToString:selectedString])
        {
            [permanentSelectionCoordinates_mm addObjectsFromArray:[self coordinatesForCurrentSelection]];
            [activeHintCoordinates_mm minusSet:[NSSet setWithArray:[self coordinatesForCurrentSelection]]];
            [self.foundWords addObject:aWord];
            
            [self.lineDrawingView addPermanentLine:[MMLine lineFromPoint:[self centerPointForCoordinate:currentStartingCoordinate] toPoint:currentEndPoint withColor:permanentLineColor_mm]];
            
            for (UILabel *aWordLabel in wordLabels_mm)
            {
                if ([aWordLabel.text isEqualToString:aWord])
                {
                    NSDictionary *strikeThroughAttribute = [NSDictionary dictionaryWithObject:@2 forKey:NSStrikethroughStyleAttributeName];
                    NSAttributedString* strikeThroughText = [[NSAttributedString alloc] initWithString:aWord attributes:strikeThroughAttribute];
                    aWordLabel.attributedText = strikeThroughText;
                }
            }
            
            if ([self.foundWords count] == [self.words count])
            {
                NSLog(@"Victory");
                UIAlertView *victoryAlertView = [[UIAlertView alloc] initWithTitle:@"You Win!" message:@"You have found all the words, greay job!" delegate:self cancelButtonTitle:@"Menu" otherButtonTitles:@"Play Again", nil];
                [victoryAlertView show];
            }
            break;
        }
    }
    
    [self.selectionLabel setText:nil];
    
    // Clear the selection
    [self.lineDrawingView setTemporaryLine:nil];
    currentStartingCoordinate = nil;
    currentEndPoint = CGPointZero;
    currentEndingCoordinate = nil;
    
    [self updateLetters];
}

#pragma mark - Update Methods

- (void)updateActiveLineForTouchPoint:(CGPoint)argPoint
{
    if (CGRectContainsPoint(overallLetterRect, argPoint))
    {
        // Update Line
        CGPoint endPoint = [self.view convertPoint:argPoint toView:self.lineDrawingView];
        currentEndPoint = [self nearestValidEndPointForPoint:endPoint];
        currentEndingCoordinate = [self coordinateNearestToPoint:currentEndPoint];
        
//        NSLog(@"Updated ending coordinate: %d, %d from last end point of %f, %f", endingCoordinate.row, endingCoordinate.column, currentEndPoint.x, currentEndPoint.y);
        
        CGPoint startingPoint = [self centerPointForCoordinate:currentStartingCoordinate];
        [self.lineDrawingView setTemporaryLine:[MMLine lineFromPoint:startingPoint toPoint:currentEndPoint withColor:activeLineColor_mm]];
        
        [self updateLetters];
        [self updateHints];
        
        [self.selectionLabel setText:[self stringForCurrentSelection]];
    }
    else
    {
//        NSLog(@"Abort tracking, went out of bounds?");
    }
}

- (void)updateLetters
{
    // Update Letters?
    NSArray *allViews = [self allViews];
    [allViews makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:16.0f]];
    [allViews makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    
    // Permanent Views
    NSArray *permanentlySelectedViews = [self viewsForPermanentSelections];
    [permanentlySelectedViews makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont boldSystemFontOfSize:16.0f]];
    
    NSArray *activelySelectedViews = [self viewsForActiveSelection];
    [activelySelectedViews makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont boldSystemFontOfSize:22.0f]];
    [activelySelectedViews makeObjectsPerformSelector:@selector(setTextColor:) withObject:[UIColor blackColor]];
}

- (void)updateGrid
{
    for (int row = 0; row < self.currentPuzzle.rows; row++)
    {
        for (int column = 0; column < self.currentPuzzle.columns; column++)
        {
            MMCoordinate *coordinate = [MMCoordinate coordinateWithRow:row column:column];
            UILabel *letterLabel = [[viewArray objectAtIndex:row] objectAtIndex:column];
            
            NSString *character = [wordGrid characterAtCoordinate:coordinate];
            if (!character)
                character = @" ";
            [letterLabel setText:character];
        }
    }
}

#pragma mark - Calculation Methods

// Could do this by having a nearestPointToPoint for direction and then a nearest of points to point for an array of points
- (CGPoint)nearestValidEndPointForPoint:(CGPoint)argPoint
{
    CGPoint currentStartingPoint = [self centerPointForCoordinate:currentStartingCoordinate];

    // Same Column (Vertical)
    CGPoint sameColumnPoint = CGPointMake(currentStartingPoint.x, argPoint.y);
    CGFloat sameColumnPointDistance = sqrtf(powf(sameColumnPoint.x - argPoint.x, 2) + powf(sameColumnPoint.y - argPoint.y, 2));
    
    // Same Row (Horizontal)
    CGPoint sameRowPoint = CGPointMake(argPoint.x, currentStartingPoint.y);
    CGFloat sameRowPointDistance = sqrtf(powf(sameRowPoint.x - argPoint.x, 2) + powf(sameRowPoint.y - argPoint.y, 2));
    
    // Diagonal
    CGFloat xDistance = fabsf(argPoint.x - currentStartingPoint.x);
    CGFloat yDistance = fabsf(argPoint.y - currentStartingPoint.y);
    CGFloat minDistance = MIN(xDistance, yDistance);
    CGFloat diagonalXValue = (argPoint.x > currentStartingPoint.x) ? (currentStartingPoint.x + minDistance) : (currentStartingPoint.x - minDistance);
    CGFloat diagonalYValue = (argPoint.y > currentStartingPoint.y) ? (currentStartingPoint.y + minDistance) : (currentStartingPoint.y - minDistance);
    CGPoint diagonalPoint = CGPointMake(diagonalXValue, diagonalYValue);
    CGFloat diagonalPointDistance = sqrtf(powf(diagonalPoint.x - argPoint.x, 2) + powf(diagonalPoint.y - argPoint.y, 2));
    
    if (sameColumnPointDistance < sameRowPointDistance && sameColumnPointDistance < diagonalPointDistance)
        return sameColumnPoint;
    
    if (sameRowPointDistance < sameColumnPointDistance && sameRowPointDistance < diagonalPointDistance)
        return sameRowPoint;
    
    return diagonalPoint;
}

- (MMCoordinate*)coordinateNearestToPoint:(CGPoint)argPoint
{
    // Compute Column
    int column = floorf(argPoint.x / labelWidth);
    
    // Compute Row
    int row = floorf(argPoint.y / labelHeight);
    
    return [MMCoordinate coordinateWithRow:row column:column];
}

- (CGPoint)centerPointForCoordinate:(MMCoordinate*)argCoordinate
{
    CGFloat xValue = (argCoordinate.column + 0.5f) * labelWidth;
    CGFloat yValue = (argCoordinate.row + 0.5f) * labelHeight;
    return CGPointMake(xValue, yValue);
}


- (NSArray*)coordinatesForCurrentSelection
{
    if (!currentStartingCoordinate)
        return nil;
    
    BOOL lastCoordinate = NO;
    
    NSMutableArray *selectedCoordinates = [NSMutableArray array];
    MMCoordinate *currentCoordinate = [MMCoordinate coordinateWithCoordinate:currentStartingCoordinate];
    
    while (!lastCoordinate)
    {
        [selectedCoordinates addObject:currentCoordinate];
        
        if ([currentCoordinate isEqualToCoordinate:currentEndingCoordinate])
        {
            lastCoordinate = YES;
        }
        
        currentCoordinate = [MMCoordinate coordinateWithCoordinate:currentCoordinate];
        
        if (currentCoordinate.row != currentEndingCoordinate.row)
            currentCoordinate.row = currentCoordinate.row + ((currentEndingCoordinate.row > currentStartingCoordinate.row) ? 1 : -1);
        
        if (currentCoordinate.column != currentEndingCoordinate.column)
            currentCoordinate.column = currentCoordinate.column + ((currentEndingCoordinate.column > currentStartingCoordinate.column) ? 1 : -1);
    }
    
    return selectedCoordinates;
}

- (NSArray*)viewsForPermanentSelections
{
    NSMutableArray *views = [NSMutableArray array];
    for (MMCoordinate *aSelectedCoordinate in permanentSelectionCoordinates_mm)
    {
        [views addObject:[[viewArray objectAtIndex:aSelectedCoordinate.row] objectAtIndex:aSelectedCoordinate.column]];
    }
    return views;
}

- (NSArray*)viewsForActiveHints
{
    NSMutableArray *views = [NSMutableArray array];
    for (MMCoordinate *anActiveHintCoordinate in activeHintCoordinates_mm)
    {
        [views addObject:[[viewArray objectAtIndex:anActiveHintCoordinate.row] objectAtIndex:anActiveHintCoordinate.column]];
    }
    return views;
}

- (NSArray*)viewsForActiveSelection
{
    NSMutableArray *views = [NSMutableArray array];
    for (MMCoordinate *aSelectedCoordinate in [self coordinatesForCurrentSelection])
    {
        [views addObject:[[viewArray objectAtIndex:aSelectedCoordinate.row] objectAtIndex:aSelectedCoordinate.column]];
    }
    return views;
}

- (NSArray*)allViews
{
    NSMutableArray *allViewsArray = [NSMutableArray array];
    for (NSArray *anArray in viewArray)
    {
        [allViewsArray addObjectsFromArray:anArray];
    }
    return allViewsArray;
}

- (NSString*)stringForCurrentSelection
{
    NSMutableString *string = [NSMutableString string];
    for (MMCoordinate *aSelectedCoordinate in [self coordinatesForCurrentSelection])
    {
        NSString *character = [wordGrid characterAtCoordinate:aSelectedCoordinate];
        [string appendString:character];
    }
    return string;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)argAlertView clickedButtonAtIndex:(NSInteger)argButtonIndex
{
    if (argButtonIndex == [argAlertView cancelButtonIndex])
    {
        // Back to menu
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        // Play again
        [self regenerate];
    }
}

#pragma mark - ADBannerViewDelegate Methods

- (void)bannerViewWillLoadAd:(ADBannerView*)argBanner
{
    NSLog(@"bannerViewWillLoadAd");
}

- (void)bannerViewDidLoadAd:(ADBannerView*)argBanner
{
    NSLog(@"bannerViewDidLoadAd");
    [argBanner setHidden:NO];
}

- (void)bannerView:(ADBannerView*)argBanner didFailToReceiveAdWithError:(NSError*)argError
{
    NSLog(@"bannerView didFailToReceiveAdWithError");
    [argBanner setHidden:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView*)argBanner willLeaveApplication:(BOOL)argWillLeave
{
    NSLog(@"bannerViewActionShouldBegin: willLeaveApplication:");
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView*)argBanner
{
    NSLog(@"bannerViewActionDidFinish");
}

@end