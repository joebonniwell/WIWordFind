//
//  MMCoordinate.h
//  WIWordFind
//
//  Created by Joe on 6/26/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCoordinate : NSObject <NSCopying>

@property (nonatomic) int row;
@property (nonatomic) int column;

+ (MMCoordinate*)coordinateWithRow:(int)argRow column:(int)argColumn;
+ (MMCoordinate*)coordinateWithCoordinate:(MMCoordinate*)argCoordinate;

- (BOOL)isEqualToCoordinate:(MMCoordinate*)argCoordinate;

@end
