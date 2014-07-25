//
//  MMAppDelegate.h
//  WIWordFind
//
//  Created by Joe on 6/24/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_DELEGATE (MMAppDelegate*)[[UIApplication sharedApplication] delegate]

@interface MMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL*)puzzleDirectoryURL;

- (int)availableHints;
- (void)decrementHints;

@end
