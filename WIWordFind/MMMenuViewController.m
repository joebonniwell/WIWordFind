//
//  MMViewController.m
//  WIWordFind
//
//  Created by Joe on 6/24/14.
//  Copyright (c) 2014 Mequon Media LLC. All rights reserved.
//

#import "MMMenuViewController.h"

#import "MMStripesBackgroundView.h"

@interface MMMenuViewController ()

@property (nonatomic, weak) IBOutlet MMStripesBackgroundView *stripesBackgroundView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

@end

@implementation MMMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.stripesBackgroundView setStripeAngle:(M_PI / 4.0f)];
    [self.stripesBackgroundView setStripeColors:@[
                                                  [UIColor colorWithRed:0.478f green:0.667f blue:0.745f alpha:1.0f],
                                                  [UIColor colorWithRed:0.424f green:0.620f blue:0.702f alpha:1.0f]
                                                  ]];
    
    [self.stripesBackgroundView setStripeWidth:40.0f];
    
    [self.playButton.layer setCornerRadius:16.0f];
    [self.playButton setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)playButtonTapped:(id)argSender
{
    [self performSegueWithIdentifier:@"ShowPuzzle" sender:nil];
}

@end
