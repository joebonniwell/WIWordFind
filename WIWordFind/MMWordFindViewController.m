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

#define TOTAL_ROWS 12
#define TOTAL_COLUMNS 12

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
    
    UIColor *activeLineColor_mm;
    UIColor *permanentLineColor_mm;
    
    NSMutableArray *wordLabels_mm;
}

@property (nonatomic, strong) MMLineDrawingView *lineDrawingView;
@property (nonatomic, strong) UILabel *selectionLabel;

@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) NSMutableArray *foundWords;

@property (nonatomic, weak) IBOutlet MMStripesBackgroundView *stripesBackgroundView;

@property (nonatomic, weak) IBOutlet ADBannerView *adBannerView;

@end

@implementation MMWordFindViewController

// TODO: Add a more dynamic layout depending on screen size and orientation

// TODO: Add a letter generation algorithm that attempts to avoid making words not in the list...

- (NSMutableArray*)arrayByAddingObjectsFromArray:(NSMutableArray*)argArray toArraysInArray:(NSMutableArray*)argExistingArrays
{
    NSMutableArray *updatedArray = [NSMutableArray array];
    for (NSArray *anExistingArray in argExistingArrays)
    {
        for (id anObjectToAdd in argArray)
        {
            NSMutableArray *anArray = [NSMutableArray arrayWithArray:anExistingArray];
            [anArray addObject:anObjectToAdd];
            [updatedArray addObject:anArray];
        }
    }
    return updatedArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.stripesBackgroundView setStripeAngle:(M_PI / 4.0f)];
    [self.stripesBackgroundView setStripeColors:@[
                                                  [UIColor colorWithRed:0.478f green:0.667f blue:0.745f alpha:1.0f],
                                                  [UIColor colorWithRed:0.424f green:0.620f blue:0.702f alpha:1.0f]
                                                  ]];
    
    [self.stripesBackgroundView setStripeWidth:40.0f];
    
    NSLog(@"%@", [[MMCoordinate coordinateWithRow:4 column:7] isEqual:[MMCoordinate coordinateWithRow:4 column:7]] ? @"OK" : @"Problem with equal");
    NSLog(@"%@", [[MMCoordinate coordinateWithRow:4 column:7] isEqual:[MMCoordinate coordinateWithRow:4 column:9]] ? @"Problem with non equal" : @"OK");

    [self setWords:@[
                     @"WISCONSIN",
                     @"CHEESE",
                     @"PACKERS",
                     @"BUCKS",
                     @"BREWERS",
                     @"BADGERS",
                     @"MILWAUKEE",
                     @"MADISON"
                     ]];
    [self setFoundWords:[NSMutableArray array]];
     
    permanentLineColor_mm = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:0.35f];
    activeLineColor_mm = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.65f];

    permanentSelectionCoordinates_mm = [NSMutableSet set];
     
    // Word Grid Generation
    wordGrid = [[MMWordGrid alloc] initWithSize:CGSizeMake(TOTAL_ROWS, TOTAL_COLUMNS)];

    [self generatePuzzleInWordGrid:wordGrid withWords:self.words];
    [wordGrid fillGridWithAlphabet];
    
    CGFloat heightOffset = (self.view.bounds.size.height - 320.0f) * 0.5f;
    
    UIView *puzzleBackingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, heightOffset, 320.0f, 320.0f)];
    [puzzleBackingView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
    [self.view addSubview:puzzleBackingView];
    [puzzleBackingView.layer setCornerRadius:10.0f];
    [puzzleBackingView setClipsToBounds:YES];
    // Then we should sort the words by the number of available positions
    
    // Need to take the dimensions of the puzzle and place the words into that grid...
    
    labelWidth = 320.0f / (1.0f * TOTAL_ROWS);
    labelHeight = 320.0f / (1.0f * TOTAL_COLUMNS);
    overallLetterRect = CGRectMake(0.0f, heightOffset, TOTAL_COLUMNS * labelWidth, TOTAL_ROWS * labelHeight);
    
    // Load labels and add to view
    viewArray = [NSMutableArray array];
    for (int row = 0; row < TOTAL_ROWS; row++)
    {
        NSMutableArray *aRowArray = [NSMutableArray array];
        [viewArray addObject:aRowArray];
        for (int column = 0; column < TOTAL_COLUMNS; column++)
        {
            UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth * column), (labelHeight * row) + heightOffset, labelWidth, labelHeight)];
            [letterLabel setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:letterLabel];
            [aRowArray addObject:letterLabel];
        }
    }
    
    [self updateGrid];
    
    [self setLineDrawingView:[[MMLineDrawingView alloc] initWithFrame:CGRectMake(0.0f, heightOffset, 320.0f, 320.0f)]];
    [self.lineDrawingView setLineWidth:30.0f];
    [self.lineDrawingView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.lineDrawingView];
    
    [self setSelectionLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, heightOffset - 30.0f, 320.0f, 30.0f)]];
    [self.selectionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.selectionLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [self.view addSubview:self.selectionLabel];
    
    // View Generation
    
    CGFloat offset = 10.0f;
    CGFloat width = 100.0f;
    CGFloat height = 16.0f;
    
    wordLabels_mm = [NSMutableArray array];
    for (int aWordLabel = 0; aWordLabel < [self.words count]; aWordLabel++)
    {
        // Layout some labels
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset + (fmodf(aWordLabel, 3) * 100.0f), 0.5f * (self.view.bounds.size.height + self.view.bounds.size.width) + (floorf(aWordLabel / 3.0f) * 16.0f), width, height)];
        [wordLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [wordLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:wordLabel];
        [wordLabel setText:[self.words objectAtIndex:aWordLabel]];
        [wordLabels_mm addObject:wordLabel];
    }
    
    [self updateLetters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// Placement Algorithm

// Place all remaining to be placed words in a mutable set

// Loop through each word and calculate how many available positions it could fit based on the current configuration

// Take the word with the least amount of available positions and randomly choose a position for it

// Remove that word from the list, repeat the analysis and placement... if at any point we end up with 0 available positions:

// Then we would need to start backing up and choosing different positions for words, which means we need some sort of tracking on which positions were tried...

- (NSArray*)calculatePositionsForWordList:(NSArray*)argWordList inGrid:(MMWordGrid*)argGrid
{
    NSMutableArray *allPositions = [NSMutableArray array];
    
    for (NSString *aWord in argWordList)
    {
        NSMutableDictionary *wordAndPositionsEntry = [NSMutableDictionary dictionaryWithObject:aWord forKey:@"Word"];
        NSMutableArray *availableWordPositions = [NSMutableArray array];
        // Horizontal
        for (int row = 0; row < [argGrid rows]; row++)
        {
            for (int column = 0; column < [argGrid columns]; column++)
            {
                // Starting coordinate...
                MMCoordinate *startingCoordinate = [MMCoordinate coordinateWithRow:row column:column];
                
                NSArray *endCoordinatesToCheck = @[
                                                    [MMCoordinate coordinateWithRow:row column:(column + ((int)[aWord length] - 1))], // East
                                                    [MMCoordinate coordinateWithRow:row column:(column - ((int)[aWord length] - 1))], // West
                                                    [MMCoordinate coordinateWithRow:(row - ((int)[aWord length] - 1)) column:column], // North
                                                    [MMCoordinate coordinateWithRow:(row + ((int)[aWord length] - 1)) column:column], // South
                                                    [MMCoordinate coordinateWithRow:(row - ((int)[aWord length] - 1)) column:(column + ((int)[aWord length] - 1))], // NE
                                                    [MMCoordinate coordinateWithRow:(row + ((int)[aWord length] - 1)) column:(column + ((int)[aWord length] - 1))], // SE
                                                    [MMCoordinate coordinateWithRow:(row + ((int)[aWord length] - 1)) column:(column - ((int)[aWord length] - 1))], // SW
                                                    [MMCoordinate coordinateWithRow:(row - ((int)[aWord length] - 1)) column:(column - ((int)[aWord length] - 1))], // NW
                                                   ];
                for (MMCoordinate *anEndCoordinate in endCoordinatesToCheck)
                {
                    MMPosition *positionToCheck = [MMPosition positionWithStartCoordinate:startingCoordinate endCoordinate:anEndCoordinate];
                    if ([argGrid isPosition:positionToCheck validForWord:aWord])
                    {
                        [availableWordPositions addObject:positionToCheck];
                    }
                }
            }
        }
        [wordAndPositionsEntry setObject:availableWordPositions forKey:@"AvailablePositions"];
        [allPositions addObject:wordAndPositionsEntry];
    }
    
//    NSLog(@"Available positions: %@", allPositions);
    
    [allPositions sortUsingComparator:^NSComparisonResult(id object1, id object2)
    {
        if ([[(NSDictionary*)object1 objectForKey:@"AvailablePositions"] count] < [[(NSDictionary*)object1 objectForKey:@"AvailablePositions"] count])
        {
            return NSOrderedAscending;
        }
        else if ([[(NSDictionary*)object1 objectForKey:@"AvailablePositions"] count] > [[(NSDictionary*)object1 objectForKey:@"AvailablePositions"] count])
        {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return allPositions;
}

- (void)updateGrid
{
    for (int row = 0; row < TOTAL_ROWS; row++)
    {
        for (int column = 0; column < TOTAL_COLUMNS; column++)
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

#pragma mark - Interaction Methods

- (void)regenerate
{
    // Should clear selection indicator as well
    [self.foundWords removeAllObjects];
    [wordGrid clearGrid];
    [self generatePuzzleInWordGrid:wordGrid withWords:self.words];
    [wordGrid fillGridWithAlphabet];
    [self updateGrid];
    [self.lineDrawingView clearAllLines];
    [permanentSelectionCoordinates_mm removeAllObjects];
    [self updateLetters];
    
    for (UILabel *aWordLabel in wordLabels_mm)
    {
//        [aWordLabel setText:aWordLabel.attributedText.string];
        [aWordLabel setAttributedText:[[NSAttributedString alloc] initWithString:aWordLabel.attributedText.string]];
    }
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
    for (NSString *aWord in self.words)
    {
        // Could check for reversed string matching as well
        if ([aWord isEqualToString:selectedString])
        {
            [permanentSelectionCoordinates_mm addObjectsFromArray:[self coordinatesForCurrentSelection]];
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
    
    // Do stuff because its over
    NSLog(@"Selected string: %@", [self stringForCurrentSelection]);
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

#pragma mark - Generation Methods

- (void)generatePuzzleInWordGrid:(MMWordGrid*)argWordGrid withWords:(NSArray*)argWords
{
    NSMutableArray *wordsToPlace = [NSMutableArray arrayWithArray:argWords];
    
    NSDate *start = [NSDate date];
    while ([wordsToPlace count])
    {
        NSArray *calculatedPositions = [self calculatePositionsForWordList:wordsToPlace inGrid:wordGrid];
        
        NSDictionary *wordToPlace = [calculatedPositions firstObject];
        NSString *word = [wordToPlace objectForKey:@"Word"];
        NSArray *availablePositionsForWord = [wordToPlace objectForKey:@"AvailablePositions"];
        // Remove already attempted positions...
        
        if ([availablePositionsForWord count] == 0)
        {
            NSLog(@"Got to available positions for word = 0");
            
            [wordGrid clearGrid];
            [wordsToPlace removeAllObjects];
            [wordsToPlace addObjectsFromArray:argWords];
            continue;
        }
        MMPosition *randomAvailablePosition = [availablePositionsForWord objectAtIndex:arc4random_uniform((int)[availablePositionsForWord count])];
        [wordGrid setString:word atPosition:randomAvailablePosition];
        [wordsToPlace removeObject:word];
        
//        NSLog(@"Placed word: %@ at %@, %d words remaining", word, randomAvailablePosition, [wordsToPlace count]);
    }
    NSLog(@"Calculation time: %f", [[NSDate date] timeIntervalSinceDate:start]);
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

// Get an array of the current coordinates in the selection

// Labels from array of coorindates

// Strings from array of coordinates

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