//
//  MMWordGrid.h
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AvailablePositions @"AvailablePositions"
#define HorizontalPositions @"HorizontalPositions"
#define VerticalPositions @"VerticalPositions"
#define DiagonalPositions @"DiagonalPositions"

@class MMCoordinate;
@class MMPosition;
@class MMWordFindPuzzle;

@interface MMWordGrid : NSObject

- (id)initWithRows:(NSInteger)argRows columns:(NSInteger)argColumns;

- (uint)rows;
- (uint)columns;

- (NSString*)characterAtCoordinate:(MMCoordinate*)argCoordinate;
- (NSString*)stringAtPosition:(MMPosition*)argPosition;
- (BOOL)isPosition:(MMPosition*)argPosition validForWord:(NSString*)aWord;

- (void)setCharacter:(NSString*)argCharacter atCoordinate:(MMCoordinate*)argCoordinate;
- (void)setString:(NSString*)argString atPosition:(MMPosition*)argPosition;

- (void)clearGrid;
- (void)fillGridWithAlphabet;
- (void)fillGridWithCharactersFromArray:(NSArray*)argArray;

- (void)configureWithPuzzle:(MMWordFindPuzzle*)argPuzzle;

- (NSDictionary*)availablePositionsForWord:(NSString*)argWord;
- (NSArray*)availablePositionsForWordList:(NSArray*)argWordList;

@end
