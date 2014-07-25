//
//  MMWordFindPuzzle.m
//  WIWordFind
//
//  Created by Joe on 6/29/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMWordFindPuzzle.h"

#import "MMPosition.h"
#import "MMCoordinate.h"
#import "MMWordGrid.h"

@interface MMWordFindPuzzle ()
{
    NSMutableArray *positions_mm;
}

@property (nonatomic, strong) NSMutableString *puzzleCharacters;

@end

@implementation MMWordFindPuzzle

- (NSString*)characterAtCoordinate:(MMCoordinate*)argCoordinate
{
    return [self.puzzleCharacters substringWithRange:NSMakeRange((argCoordinate.column + (argCoordinate.row * self.columns)), 1)];
}

#pragma mark - Puzzle / JSON Conversion Methods

+ (MMWordFindPuzzle*)randomPuzzleWithRows:(NSInteger)argRows columns:(NSInteger)argColumns matchStrings:(NSArray*)argMatchStrings
{
    // TODO: Weight fill letters higher for the frequency they occur in the match strings
    // TODO: Do some checks to make sure that shorter match strings arent substrings of longer match strings
    // TODO: Could do false positive checks for everywhere else but the selected position for match strings
    
    MMWordFindPuzzle *aPuzzle = [[MMWordFindPuzzle alloc] init];
    [aPuzzle setRows:argRows];
    [aPuzzle setColumns:argColumns];
    [aPuzzle setMatchStrings:argMatchStrings];
    
    MMWordGrid *wordGrid = [[MMWordGrid alloc] initWithRows:argRows columns:argColumns];
    
    NSMutableArray *wordsToPlace = [NSMutableArray arrayWithArray:argMatchStrings];
    [wordsToPlace sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"length" ascending:NO]]];
    NSMutableDictionary *placedWordsAndPositions = [NSMutableDictionary dictionary];
    // TODO: Add a placed words dictionary to keep track of the order coordinated with word positions
    
    // Problem is that we are setting the match strings in the order they arrive, but the chosen positions are being determined via an ordered word length sort, and therefore the order of the word positions at the end of the generation does not match the order of the words in match strings...
    
    // So we somehow need to coordinate word positions with the order of match strings
    
    // We could set match strings based on a placed word and chosen positions arrays that are generated at the same time, but then we would have a largest to smallest word ordering in match strings and it may/may not match the display strings, wich is attached seperately (outside this generation function)...
    
    // So it seems the proper solution would be to tie the chosen positions to the word and re-sort the chosen positions array to match the match strings array during this generation call...
    
    
    int horizontalPositionsUsed = 0;
    int verticalPositionsUsed = 0;
    int diagonalPositionsUsed = 0;
    
    while ([wordsToPlace count])
    {
        NSArray *calculatedPositions = [wordGrid availablePositionsForWordList:wordsToPlace];
        
        NSDictionary *wordToPlace = [calculatedPositions firstObject];
        NSString *word = [wordToPlace objectForKey:@"Word"];
        
        MMPosition *chosenPosition = nil;
        
        NSArray *horizontalPositionsForWord = [[wordToPlace objectForKey:AvailablePositions] objectForKey:HorizontalPositions];
        NSArray *verticalPositionsForWord = [[wordToPlace objectForKey:AvailablePositions] objectForKey:VerticalPositions];
        NSArray *diagonalPositionsForWord = [[wordToPlace objectForKey:AvailablePositions] objectForKey:DiagonalPositions];
        
        if (horizontalPositionsUsed || verticalPositionsUsed || diagonalPositionsUsed)
        {
            if (horizontalPositionsUsed <= verticalPositionsUsed && horizontalPositionsUsed <= diagonalPositionsUsed)
            {
                if ([horizontalPositionsForWord count])
                {
                    chosenPosition = [horizontalPositionsForWord objectAtIndex:arc4random_uniform((int)[horizontalPositionsForWord count])];
                    horizontalPositionsUsed++;
                }
            }
            else if (verticalPositionsUsed <= horizontalPositionsUsed && verticalPositionsUsed <= diagonalPositionsUsed)
            {
                if ([verticalPositionsForWord count])
                {
                    chosenPosition = [verticalPositionsForWord objectAtIndex:arc4random_uniform((int)[verticalPositionsForWord count])];
                    verticalPositionsUsed++;
                }
            }
            else if (diagonalPositionsUsed <= horizontalPositionsUsed && diagonalPositionsUsed <= verticalPositionsUsed)
            {
                if ([diagonalPositionsForWord count])
                {
                    chosenPosition = [diagonalPositionsForWord objectAtIndex:arc4random_uniform((int)[diagonalPositionsForWord count])];
                    diagonalPositionsUsed++;
                }
            }
        }


        if (!chosenPosition)
        {
            NSMutableArray *allAvailablePositions = [NSMutableArray array];
            [allAvailablePositions addObjectsFromArray:horizontalPositionsForWord];
            [allAvailablePositions addObjectsFromArray:verticalPositionsForWord];
            [allAvailablePositions addObjectsFromArray:diagonalPositionsForWord];
            
            if ([allAvailablePositions count])
            {
                chosenPosition = [allAvailablePositions objectAtIndex:arc4random_uniform((int)[allAvailablePositions count])];
                // Increment appropriate counter
                if ([chosenPosition positionDirection] == MMPositionDirectionHorizontal) {horizontalPositionsUsed++;}
                else if ([chosenPosition positionDirection] == MMPositionDirectionVertical) {verticalPositionsUsed++;}
                else {diagonalPositionsUsed++;}
            }
        }
        
        if (!chosenPosition)
        {
            
            NSLog(@"Got to available positions for word = 0");
            
            [wordGrid clearGrid];
            [wordsToPlace removeAllObjects];
            [wordsToPlace addObjectsFromArray:argMatchStrings];
            [placedWordsAndPositions removeAllObjects];
            continue;
        }
//        MMPosition *randomAvailablePosition = [availablePositionsForWord objectAtIndex:arc4random_uniform((int)[availablePositionsForWord count])];
        [wordGrid setString:word atPosition:chosenPosition];
        [placedWordsAndPositions setObject:chosenPosition forKey:word];
        [wordsToPlace removeObject:word];
        
        //        NSLog(@"Placed word: %@ at %@, %d words remaining", word, randomAvailablePosition, [wordsToPlace count]);
    }
    
    for (NSString *aKey in [placedWordsAndPositions allKeys])
    {
        NSLog(@"%@ %@", aKey, [placedWordsAndPositions objectForKey:aKey]);
    }
    [wordGrid fillGridWithAlphabet];
    
    NSMutableString *allGridCharacters = [NSMutableString string];
    for (int row = 0; row < wordGrid.rows; row++)
    {
        for (int column = 0; column < wordGrid.columns; column++)
        {
            [allGridCharacters appendString:[wordGrid characterAtCoordinate:[MMCoordinate coordinateWithRow:row column:column]]];
        }
    }
    
    [aPuzzle setPuzzleCharacters:allGridCharacters];
    
    // Sort
    NSMutableArray *chosenWordPositions = [NSMutableArray array];
    for (NSString *aWord in aPuzzle.matchStrings)
    {
        [chosenWordPositions addObject:[placedWordsAndPositions objectForKey:aWord]];
    }
    [aPuzzle setWordPostions:chosenWordPositions];
    
    return aPuzzle;
}

- (id)initWithJSON:(NSData*)argJSON
{
    if ((self = [super init]))
    {
        NSMutableArray *displayStrings_mm = [NSMutableArray array];
        NSMutableArray *matchStrings_mm = [NSMutableArray array];
        NSMutableArray *wordPositions_mm = [NSMutableArray array];
        
        NSError *error;
        NSDictionary *puzzleJSONObject = [NSJSONSerialization JSONObjectWithData:argJSON options:0 error:&error];
        if (!puzzleJSONObject)
        {
            NSLog(@"Error parsing puzzle JSON: %@", error);
            return nil;
        }
        
        [self setPuzzleCharacters:[NSMutableString stringWithString:[puzzleJSONObject objectForKey:PuzzleJSON_PuzzleCharacters]]];
        
        NSArray *puzzleWords = [puzzleJSONObject objectForKey:PuzzleJSON_PuzzleWords];
        
        for (NSDictionary *aWord in puzzleWords)
        {
            [displayStrings_mm addObject:[aWord objectForKey:PuzzleJSON_WordDisplayString]];
            [matchStrings_mm addObject:[aWord objectForKey:PuzzleJSON_WordMatchString]];
            [wordPositions_mm addObject:[MMPosition positionWithJSONRepresentation:[aWord objectForKey:PuzzleJSON_WordPosition]]];
        }
        
        [self setDisplayStrings:displayStrings_mm];
        [self setMatchStrings:matchStrings_mm];
        [self setWordPostions:wordPositions_mm];
        [self setPuzzleName:[puzzleJSONObject objectForKey:PuzzleJSON_PuzzleName]];
        [self setRows:[[puzzleJSONObject objectForKey:PuzzleJSON_PuzzleRows] intValue]];
        [self setColumns:[[puzzleJSONObject objectForKey:PuzzleJSON_PuzzleColumns] intValue]];
    }
    return self;
}

+ (MMWordFindPuzzle*)puzzleFromJSON:(NSData*)argJSON
{
    MMWordFindPuzzle *aPuzzle = [[MMWordFindPuzzle alloc] initWithJSON:argJSON];
    return aPuzzle;
}

- (NSData*)JSONRepresentation
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    
    [jsonDictionary setObject:self.puzzleCharacters forKey:PuzzleJSON_PuzzleCharacters];
    
    NSMutableArray *puzzleWords = [NSMutableArray array];
    for (int aWordIndex = 0; aWordIndex < [self.displayStrings count]; aWordIndex++)
    {
        NSDictionary *aWordDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [self.displayStrings objectAtIndex:aWordIndex], PuzzleJSON_WordDisplayString,
                                         [self.matchStrings objectAtIndex:aWordIndex], PuzzleJSON_WordMatchString,
                                         [[self.wordPostions objectAtIndex:aWordIndex] JSONRepresentation], PuzzleJSON_WordPosition,
                                         nil];
        [puzzleWords addObject:aWordDictionary];
    }
    [jsonDictionary setObject:puzzleWords forKey:PuzzleJSON_PuzzleWords];
    
    [jsonDictionary setObject:(self.puzzleName ? self.puzzleName : @"") forKey:PuzzleJSON_PuzzleName];
    [jsonDictionary setObject:[NSNumber numberWithInt:self.rows] forKey:PuzzleJSON_PuzzleRows];
    [jsonDictionary setObject:[NSNumber numberWithInt:self.columns] forKey:PuzzleJSON_PuzzleColumns];
    
    NSError *error = nil;
    NSData *puzzleJSON = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    if (!puzzleJSON)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    return puzzleJSON;
}

- (NSString*)puzzleSummary
{
    // Create a mutable string
    // Set number and type of puzzle solutions
    
    int totalHorizontalPositions = 0;
    int totalVerticalPositions = 0;
    int totalDiagonalPositions = 0;
    
    for (MMPosition *aPosition in self.wordPostions)
    {
        if (aPosition.startCoordinate.row == aPosition.endCoordinate.row)
        {
            totalHorizontalPositions++;
        }
        else if (aPosition.startCoordinate.column == aPosition.endCoordinate.column)
        {
            totalVerticalPositions++;
        }
        else
        {
            totalDiagonalPositions++;
        }
    }
    return [NSString stringWithFormat:@"\nTotal Horizontal Positions: %d\nTotal Vertical Positions: %d\nTotal Diagonal Positions: %d", totalHorizontalPositions, totalVerticalPositions, totalDiagonalPositions];
}

@end
