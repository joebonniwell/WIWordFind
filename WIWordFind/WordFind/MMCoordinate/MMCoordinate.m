//
//  MMCoordinate.m
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMCoordinate.h"

@implementation MMCoordinate

+ (MMCoordinate*)coordinateWithRow:(int)argRow column:(int)argColumn
{
    MMCoordinate *aCoordinate = [[MMCoordinate alloc] init];
    [aCoordinate setRow:argRow];
    [aCoordinate setColumn:argColumn];
    return aCoordinate;
}

+ (MMCoordinate*)coordinateWithCoordinate:(MMCoordinate*)argCoordinate
{
    if (!argCoordinate)
        return nil;
    
    MMCoordinate *aCoordinate = [[MMCoordinate alloc] init];
    [aCoordinate setRow:argCoordinate.row];
    [aCoordinate setColumn:argCoordinate.column];
    return aCoordinate;
}

- (id)copyWithZone:(NSZone*)argZone
{
    return [MMCoordinate coordinateWithCoordinate:self];
}

- (NSUInteger)hash
{
    return (100 * self.row) + (1000 * self.column);
}

- (BOOL)isEqual:(id)argObject
{
    if (argObject == self)
        return YES;
    if (!argObject || ![argObject isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCoordinate:argObject];
}

- (BOOL)isEqualToCoordinate:(MMCoordinate*)argCoordinate
{
    if (argCoordinate.row == self.row && argCoordinate.column == self.column)
        return YES;
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ row: %d column: %d", [super description], self.row, self.column];
}

@end
