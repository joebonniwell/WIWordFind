//
//  MMAppDelegate.m
//  WIWordFind
//
//  Created by Joe on 6/24/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMAppDelegate.h"

#import "MMWordFindPuzzle.h"

@interface MMAppDelegate ()
{
    NSURL *puzzleDirectoryURL_mm;
    int hints_mm;
}

@end

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    hints_mm = 5;
    // TODO:
    
    // Make a puzzle directory
    
    // Check the bundle for default puzzles and add them to the puzzle directory if they aren't there
    NSArray *defaultPuzzleURLs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"mmpuzzle" subdirectory:nil];
    for (NSURL *aDefaultPuzzleURL in defaultPuzzleURLs)
    {
        // Copy the puzzle to the puzzle directory
        NSError *puzzleCopyError = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:aDefaultPuzzleURL toURL:[[self puzzleDirectoryURL] URLByAppendingPathComponent:[aDefaultPuzzleURL lastPathComponent]] error:&puzzleCopyError])
        {
            NSLog(@"Error copying puzzle: %@", [puzzleCopyError userInfo]);
        }
    }
    
    // Hints should cause a random un found word to be selected, and a random letter of that word chosen, and that position is highlighted to the user via a blinking circle that only goes away once the word is selected... The hint count should also decrement with use and we should have a method of adding hints
    
    MMWordFindPuzzle *aPuzzle = [MMWordFindPuzzle randomPuzzleWithRows:12 columns:12 matchStrings:@[
                                                                                                        @"CLOONEY",
                                                                                                        @"MAC",
                                                                                                        @"PITT",
                                                                                                        @"GOULD",
                                                                                                        @"AFFLECK",
                                                                                                        @"CAAN",
                                                                                                        @"QIN",
                                                                                                        @"REINER",
                                                                                                        @"DAMON",
                                                                                                        @"GARCIA",
                                                                                                        @"ROBERTS",
                                                                                                        @"CHEADLE"
                                                                                                    ]];
    [aPuzzle setDisplayStrings:@[
                                 @"CLOONEY",
                                 @"MAC",
                                 @"PITT",
                                 @"GOULD",
                                 @"AFFLECK",
                                 @"CAAN",
                                 @"QIN",
                                 @"REINER",
                                 @"DAMON",
                                 @"GARCIA",
                                 @"ROBERTS",
                                 @"CHEADLE"
    ]];
    
    [aPuzzle setPuzzleName:@"Ocean's 11"];
    NSLog(@"Random puzzle json: %@", [aPuzzle JSONRepresentation]);
    NSLog(@"Puzzle configuration: %@", [aPuzzle puzzleSummary]);
    
    for (int index = 0; index < [[aPuzzle matchStrings] count]; index++)
    {
        NSLog(@"%@ %@ %@", [[aPuzzle matchStrings] objectAtIndex:index], [[aPuzzle displayStrings] objectAtIndex:index], [[aPuzzle wordPostions] objectAtIndex:index]);
    }
    // Write to a file
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *generatedPuzzlesDirectoryURL_mm = [documentsURL URLByAppendingPathComponent:@"GeneratedPuzzles" isDirectory:YES];
    NSError *directoryCreationError = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:generatedPuzzlesDirectoryURL_mm withIntermediateDirectories:YES attributes:nil error:&directoryCreationError])
    {
        NSLog(@"Directory creation error: %@", [directoryCreationError localizedDescription]);
    }
    
    [[aPuzzle JSONRepresentation] writeToURL:[generatedPuzzlesDirectoryURL_mm URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mmpuzzle", [aPuzzle puzzleName]]] atomically:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)defaultPuzzles
{
    // Puzzles
    
    NSDictionary *aPuzzle = @{
                                // Puzzle Name
                                // Puzzle Size
                                // Puzzle Display Strings
                                // Puzzle Matching Strings
                                // Puzzle Characters
                              };
    
}

#pragma mark - Hints

- (int)availableHints
{
    return hints_mm;
}

- (void)decrementHints
{
    hints_mm--;
}

#pragma mark - Puzzle Directory URL

- (NSURL*)puzzleDirectoryURL
{
    if (!puzzleDirectoryURL_mm)
    {
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        puzzleDirectoryURL_mm = [documentsURL URLByAppendingPathComponent:@"Puzzles" isDirectory:YES];
        NSError *directoryCreationError = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:puzzleDirectoryURL_mm withIntermediateDirectories:YES attributes:nil error:&directoryCreationError])
        {
            NSLog(@"Directory creation error: %@", [directoryCreationError localizedDescription]);
        }
    }
    return puzzleDirectoryURL_mm;
}

@end
