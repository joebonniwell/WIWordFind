//
//  MMPosition.h
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCoordinate;

@interface MMPosition : NSObject <NSCopying>

@property (nonatomic, strong) MMCoordinate *startCoordinate;
@property (nonatomic, strong) MMCoordinate *endCoordinate;

+ (MMPosition*)positionWithStartCoordinate:(MMCoordinate*)argStartCoordinate endCoordinate:(MMCoordinate*)argEndCoordinate;

- (BOOL)isEqualToPosition:(MMPosition*)argPosition;
- (uint)length;
- (int)rowDirection;
- (int)columnDirection;

@end
