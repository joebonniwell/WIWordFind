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

@end
