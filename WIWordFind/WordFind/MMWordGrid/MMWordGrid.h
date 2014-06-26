//
//  MMWordGrid.h
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCoordinate;
@class MMPosition;

@interface MMWordGrid : NSObject

- (id)initWithSize:(CGSize)argSize;

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

@end
