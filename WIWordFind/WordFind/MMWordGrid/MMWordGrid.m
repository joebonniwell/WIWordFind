//
//  MMWordGrid.m
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMWordGrid.h"
#import "MMCoordinate.h"
#import "MMPosition.h"
#import "MMWordFindPuzzle.h"

@interface MMWordGrid ()
{
    uint rows_mm;
    uint columns_mm;
    
    NSMutableDictionary *grid_mm;
}

@end

@implementation MMWordGrid

- (id)initWithRows:(NSInteger)argRows columns:(NSInteger)argColumns
{
    if ((self = [super init]))
    {
        rows_mm = argRows;
        columns_mm = argColumns;
        grid_mm = [[NSMutableDictionary alloc] initWithCapacity:(rows_mm * columns_mm)];
    }
    return self;
}

#pragma mark - Puzzle Generation Methods

- (NSDictionary*)availablePositionsForWord:(NSString*)argWord
{
    NSMutableArray *availableHorizontalPositions = [NSMutableArray array];
    NSMutableArray *availableVerticalPositions = [NSMutableArray array];
    NSMutableArray *availableDiagonalPositions = [NSMutableArray array];
    
    for (int row = 0; row < [self rows]; row++)
    {
        for (int column = 0; column < [self columns]; column++)
        {
            // Starting coordinate...
            MMCoordinate *startingCoordinate = [MMCoordinate coordinateWithRow:row column:column];
            
            NSArray *horizontalEndCoordinatesToCheck = @[
                                                         [MMCoordinate coordinateWithRow:row column:(column + ((int)[argWord length] - 1))], // East
                                                         [MMCoordinate coordinateWithRow:row column:(column - ((int)[argWord length] - 1))], // West
                                                         ];
            NSArray *verticalEndCoordinatesToCheck = @[
                                                       [MMCoordinate coordinateWithRow:(row - ((int)[argWord length] - 1)) column:column], // North
                                                       [MMCoordinate coordinateWithRow:(row + ((int)[argWord length] - 1)) column:column], // South
                                                       ];
            NSArray *diagonalEndCoordinatesToCheck = @[
                                                       [MMCoordinate coordinateWithRow:(row - ((int)[argWord length] - 1)) column:(column + ((int)[argWord length] - 1))], // NE
                                                       [MMCoordinate coordinateWithRow:(row + ((int)[argWord length] - 1)) column:(column + ((int)[argWord length] - 1))], // SE
                                                       [MMCoordinate coordinateWithRow:(row + ((int)[argWord length] - 1)) column:(column - ((int)[argWord length] - 1))], // SW
                                                       [MMCoordinate coordinateWithRow:(row - ((int)[argWord length] - 1)) column:(column - ((int)[argWord length] - 1))], // NW
                                                       ];
            for (MMCoordinate *anEndCoordinate in horizontalEndCoordinatesToCheck)
            {
                MMPosition *positionToCheck = [MMPosition positionWithStartCoordinate:startingCoordinate endCoordinate:anEndCoordinate];
                if ([self isPosition:positionToCheck validForWord:argWord])
                {
                    [availableHorizontalPositions addObject:positionToCheck];
                }
            }
            
            for (MMCoordinate *anEndCoordinate in verticalEndCoordinatesToCheck)
            {
                MMPosition *positionToCheck = [MMPosition positionWithStartCoordinate:startingCoordinate endCoordinate:anEndCoordinate];
                if ([self isPosition:positionToCheck validForWord:argWord])
                {
                    [availableVerticalPositions addObject:positionToCheck];
                }
            }
            
            for (MMCoordinate *anEndCoordinate in diagonalEndCoordinatesToCheck)
            {
                MMPosition *positionToCheck = [MMPosition positionWithStartCoordinate:startingCoordinate endCoordinate:anEndCoordinate];
                if ([self isPosition:positionToCheck validForWord:argWord])
                {
                    [availableDiagonalPositions addObject:positionToCheck];
                }
            }
        }
    }
    
    return @{HorizontalPositions:availableHorizontalPositions, VerticalPositions:availableVerticalPositions, DiagonalPositions:availableDiagonalPositions};
}

- (NSArray*)availablePositionsForWordList:(NSArray*)argWordList
{
    NSMutableArray *allPositions = [NSMutableArray array];
    
    for (NSString *aWord in argWordList)
    {
        NSMutableDictionary *wordAndPositionsEntry = [NSMutableDictionary dictionaryWithObject:aWord forKey:@"Word"];
        NSDictionary *availableWordPositions = [self availablePositionsForWord:aWord];
        [wordAndPositionsEntry setObject:availableWordPositions forKey:AvailablePositions];
        [allPositions addObject:wordAndPositionsEntry];
    }
    
    [allPositions sortUsingComparator:^NSComparisonResult(id object1, id object2)
    {
        NSDictionary *wordAndPositionEntry1 = (NSDictionary*)object1;
        NSDictionary *wordAndPositionEntry2 = (NSDictionary*)object2;
        
        int availablePositions1 =   [[wordAndPositionEntry1 objectForKey:HorizontalPositions] count] +
                                    [[wordAndPositionEntry1 objectForKey:VerticalPositions] count] +
                                    [[wordAndPositionEntry1 objectForKey:DiagonalPositions] count];
        
        int availablePositions2 =   [[wordAndPositionEntry2 objectForKey:HorizontalPositions] count] +
                                    [[wordAndPositionEntry2 objectForKey:VerticalPositions] count] +
                                    [[wordAndPositionEntry2 objectForKey:DiagonalPositions] count];

        if (availablePositions1 > availablePositions2)
            return NSOrderedAscending;
        else if (availablePositions1 < availablePositions2)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    return allPositions;
}

#pragma mark - Word Grid Values

- (uint)rows
{
    return rows_mm;
}

- (uint)columns
{
    return columns_mm;
}

#pragma mark - Status Methods

- (BOOL)isPosition:(MMPosition*)argPosition validForWord:(NSString*)aWord
{
    if ([argPosition length] != [aWord length]) {return NO;}
    if (argPosition.startCoordinate.row < 0) {return NO;}
    if (argPosition.startCoordinate.column < 0) {return NO;}
    if (argPosition.endCoordinate.row < 0) {return NO;}
    if (argPosition.endCoordinate.column < 0) {return NO;}
    if (argPosition.startCoordinate.row >= [self rows]) {return NO;}
    if (argPosition.startCoordinate.column >= [self columns]) {return NO;}
    if (argPosition.endCoordinate.row >= [self rows]) {return NO;}
    if (argPosition.endCoordinate.column >= [self columns]) {return NO;}
    
    for (int characterIndex = 0; characterIndex < [aWord length]; characterIndex++)
    {
        int currentRow = argPosition.startCoordinate.row + (characterIndex * [argPosition rowDirection]);
        int currentColumn = argPosition.startCoordinate.column + (characterIndex * [argPosition columnDirection]);
        
        NSString *characterAtColumn = [self characterAtCoordinate:[MMCoordinate coordinateWithRow:currentRow column:currentColumn]];
        if (characterAtColumn)
        {
            NSString *currentCharacter = [aWord substringWithRange:NSMakeRange(characterIndex, 1)];
            if (![characterAtColumn isEqualToString:currentCharacter])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSString*)characterAtCoordinate:(MMCoordinate*)argCoordinate
{
    return [grid_mm objectForKey:argCoordinate];
}

- (NSString*)stringAtPosition:(MMPosition*)argPosition
{
    NSMutableString *string = [NSMutableString string];
    for (int characterIndex = 0; characterIndex < [argPosition length]; characterIndex++)
    {
        int currentRow = argPosition.startCoordinate.row + (characterIndex * [argPosition rowDirection]);
        int currentColumn = argPosition.startCoordinate.column + (characterIndex * [argPosition columnDirection]);
        
        NSString *characterAtCoordinate = [self characterAtCoordinate:[MMCoordinate coordinateWithRow:currentRow column:currentColumn]];
        if (!characterAtCoordinate)
            return nil;
        
        [string appendString:characterAtCoordinate];
    }
    return string;
}

#pragma mark - Update Methods

- (void)setCharacter:(NSString*)argCharacter atCoordinate:(MMCoordinate*)argCoordinate
{
    // Assertions to make sure coordinate is within grid?
    NSAssert(argCoordinate.row < [self rows], @"Start coordinate row (%d) is outside of grid with (%d) rows", argCoordinate.row, [self rows]);
    NSAssert(argCoordinate.column < [self columns], @"Start coordinate column (%d) is outside of grid with (%d) columns", argCoordinate.column, [self columns]);
    if (!argCharacter)
    {
        [grid_mm removeObjectForKey:argCoordinate];
        return;
    }
    [grid_mm setObject:argCharacter forKey:argCoordinate];
}

- (void)setString:(NSString*)argString atPosition:(MMPosition*)argPosition
{
    NSAssert([argPosition length] == [argString length], @"Position size (%d) is not equal to string size (%d)", [argPosition length], [argString length]);
    NSAssert([argPosition startCoordinate].row < [self rows], @"Start coordinate row (%d) is outside of grid with (%d) rows", [argPosition startCoordinate].row, [self rows]);
    NSAssert([argPosition startCoordinate].column < [self columns], @"Start coordinate column (%d) is outside of grid with (%d) columns", [argPosition startCoordinate].column, [self columns]);
    NSAssert([argPosition endCoordinate].row < [self rows], @"End coordinate row (%d) is outside of grid with (%d) rows", [argPosition endCoordinate].row, [self rows]);
    NSAssert([argPosition endCoordinate].column < [self columns], @"End coordinate column (%d) is outside of grid with (%d) columns", [argPosition endCoordinate].column, [self columns]);
    
    for (int characterIndex = 0; characterIndex < [argString length]; characterIndex++) // This should be over the position...? Otherwise how to remove word from grid?
    {
        int currentRow = argPosition.startCoordinate.row + (characterIndex * [argPosition rowDirection]);
        int currentColumn = argPosition.startCoordinate.column + (characterIndex * [argPosition columnDirection]);
        
        [self setCharacter:[argString substringWithRange:NSMakeRange(characterIndex, 1)] atCoordinate:[MMCoordinate coordinateWithRow:currentRow column:currentColumn]];
    }
}

#pragma mark - Full WordGrid Manipulation

- (void)clearGrid
{
    [grid_mm removeAllObjects];
}

- (void)fillGridWithAlphabet
{
    NSArray *alphabet = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    [self fillGridWithCharactersFromArray:alphabet];
}

- (void)fillGridWithCharactersFromArray:(NSArray*)argArray
{
    for (int row = 0; row < self.rows; row++)
    {
        for (int column = 0; column < self.columns; column++)
        {
            MMCoordinate *coordinate = [MMCoordinate coordinateWithRow:row column:column];
            if (![self characterAtCoordinate:coordinate])
            {
                [self setCharacter:[argArray objectAtIndex:arc4random_uniform([argArray count])] atCoordinate:coordinate];
            }
        }
    }
}

#pragma mark - Puzzle Configuration Methods

- (void)configureWithPuzzle:(MMWordFindPuzzle*)argPuzzle
{
    for (int row = 0; row < self.rows; row++)
    {
        for (int column = 0; column < self.columns; column++)
        {
            MMCoordinate *coordinate = [MMCoordinate coordinateWithRow:row column:column];
            NSString *character = [argPuzzle characterAtCoordinate:coordinate];
            [self setCharacter:character atCoordinate:coordinate];
        }
    }
}

@end
