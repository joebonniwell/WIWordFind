//
//  MMPosition.m
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMPosition.h"

#import "MMCoordinate.h"

@implementation MMPosition

+ (MMPosition*)positionWithStartCoordinate:(MMCoordinate*)argStartCoordinate endCoordinate:(MMCoordinate*)argEndCoordinate
{
    MMPosition *aPosition = [[MMPosition alloc] init];
    [aPosition setStartCoordinate:argStartCoordinate];
    [aPosition setEndCoordinate:argEndCoordinate];
    return aPosition;
}

- (id)copyWithZone:(NSZone*)argZone
{
    return [MMPosition positionWithStartCoordinate:[self.startCoordinate copy] endCoordinate:[self.endCoordinate copy]];
}

- (BOOL)isEqual:(id)argObject
{
    if (argObject == self)
        return YES;
    if (!argObject || ![argObject isKindOfClass:[self class]])
        return NO;
    return [self isEqualToPosition:argObject];
}

- (BOOL)isEqualToPosition:(MMPosition*)argPosition
{
    if ([argPosition.startCoordinate isEqual:self.startCoordinate] && [argPosition.endCoordinate isEqual:self.endCoordinate])
        return YES;
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ start: %@ end: %@", [super description], self.startCoordinate, self.endCoordinate];
}

- (uint)length
{
    uint rowLength = fabsf(self.startCoordinate.row - self.endCoordinate.row) + 1;
    uint columnLength = fabsf(self.startCoordinate.column - self.endCoordinate.column) + 1;
    
    return MAX(rowLength, columnLength);
}

- (int)rowDirection
{
    return (self.startCoordinate.row < self.endCoordinate.row) ? 1 : ((self.startCoordinate.row > self.endCoordinate.row) ? -1 : 0);
}

- (int)columnDirection
{
    return (self.startCoordinate.column < self.endCoordinate.column) ? 1 : ((self.startCoordinate.column > self.endCoordinate.column) ? -1 : 0);
}

- (MMPositionDirection)positionDirection
{
    if (self.startCoordinate.row == self.endCoordinate.row)
    {
        return MMPositionDirectionHorizontal;
    }
    else if (self.startCoordinate.column == self.endCoordinate.column)
    {
        return MMPositionDirectionVertical;
    }
    return MMPositionDirectionDiagonal;
}

- (MMCoordinate*)randomCoodinate
{
    NSArray *allCoordinates = [self coordinates];
    return [allCoordinates objectAtIndex:arc4random_uniform([allCoordinates count])];
}

- (NSArray*)coordinates
{
    NSMutableArray *allCoordinates = [NSMutableArray array];
    
    int currentRow = self.startCoordinate.row;
    int currentColumn = self.startCoordinate.column;
    
    do {
        MMCoordinate *aCoordinate = [MMCoordinate coordinateWithRow:currentRow column:currentColumn];
        [allCoordinates addObject:aCoordinate];
        currentRow += [self rowDirection];
        currentColumn += [self columnDirection];
    } while (currentRow != self.endCoordinate.row || currentColumn != self.endCoordinate.column);
    
    [allCoordinates addObject:self.endCoordinate];
    
    return allCoordinates;
}

#pragma mark - JSON

- (NSArray*)JSONRepresentation
{
    return @[
                @[[NSNumber numberWithInt:self.startCoordinate.row], [NSNumber numberWithInt:self.startCoordinate.column]],
                @[[NSNumber numberWithInt:self.endCoordinate.row], [NSNumber numberWithInt:self.endCoordinate.column]]
            ];
}

+ (MMPosition*)positionWithJSONRepresentation:(NSArray*)argJSON
{
    if ([argJSON count] != 2)
    {
        return nil;
    }
    
    int startCoordinateRow = [[[argJSON objectAtIndex:0] objectAtIndex:0] intValue];
    int startCoordinateColumn = [[[argJSON objectAtIndex:0] objectAtIndex:1] intValue];
    MMCoordinate *startCoordinate = [MMCoordinate coordinateWithRow:startCoordinateRow column:startCoordinateColumn];
    
    int endCoordinateRow = [[[argJSON objectAtIndex:1] objectAtIndex:0] intValue];
    int endCoordinateColumn = [[[argJSON objectAtIndex:1] objectAtIndex:1] intValue];
    MMCoordinate *endCoodinate = [MMCoordinate coordinateWithRow:endCoordinateRow column:endCoordinateColumn];
    
    return [MMPosition positionWithStartCoordinate:startCoordinate endCoordinate:endCoodinate];
}

@end
