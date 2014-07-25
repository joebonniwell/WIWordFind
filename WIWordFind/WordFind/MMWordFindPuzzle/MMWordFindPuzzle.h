//
//  MMWordFindPuzzle.h
//  WIWordFind
//
//  Created by Joe on 6/29/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PuzzleJSON_PuzzleCharacters @"PuzzleCharacters"
#define PuzzleJSON_PuzzleName @"PuzzleName"
#define PuzzleJSON_PuzzleWords @"PuzzleWords"
#define PuzzleJSON_PuzzleRows @"PuzzleRows"
#define PuzzleJSON_PuzzleColumns @"PuzzleColumns"
#define PuzzleJSON_WordDisplayString @"DisplayString"
#define PuzzleJSON_WordMatchString @"MatchString"
#define PuzzleJSON_WordPosition @"PuzzleJSON_WordPosition"

@class MMCoordinate;

@interface MMWordFindPuzzle : NSObject

@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger columns;
@property (nonatomic, strong) NSArray *matchStrings;
@property (nonatomic, strong) NSArray *displayStrings;
@property (nonatomic, strong) NSArray *wordPostions;
@property (nonatomic, strong) NSString *puzzleName;

- (NSString*)characterAtCoordinate:(MMCoordinate*)argCoordinate;

#pragma mark - Puzzle / JSON Conversion Methods

+ (MMWordFindPuzzle*)randomPuzzleWithRows:(NSInteger)argRows columns:(NSInteger)argColumns matchStrings:(NSArray*)argMatchStrings;

+ (MMWordFindPuzzle*)puzzleFromJSON:(NSData*)argJSON;
- (NSData*)JSONRepresentation;

- (NSString*)puzzleSummary;

@end
