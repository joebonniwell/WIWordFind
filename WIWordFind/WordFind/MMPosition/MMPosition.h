//
//  MMPosition.h
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCoordinate;

typedef enum {
    MMPositionDirectionNone = 0,
    MMPositionDirectionHorizontal = 1,
    MMPositionDirectionVertical = 2,
    MMPositionDirectionDiagonal = 3
    
} MMPositionDirection;
@interface MMPosition : NSObject <NSCopying>

@property (nonatomic, strong) MMCoordinate *startCoordinate;
@property (nonatomic, strong) MMCoordinate *endCoordinate;

+ (MMPosition*)positionWithStartCoordinate:(MMCoordinate*)argStartCoordinate endCoordinate:(MMCoordinate*)argEndCoordinate;

- (BOOL)isEqualToPosition:(MMPosition*)argPosition;
- (uint)length;
- (int)rowDirection;
- (int)columnDirection;
- (MMPositionDirection)positionDirection;
- (MMCoordinate*)randomCoodinate;
- (NSArray*)coordinates;
- (NSArray*)JSONRepresentation;
+ (MMPosition*)positionWithJSONRepresentation:(NSArray*)argJSON;

@end
