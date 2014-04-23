//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"
#import "MSPUpNextViewController.h"

@interface MSPNowPlayingViewController ()

@end

@implementation MSPNowPlayingViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Set color scheme
    [self setColorScheme:MSPColorSchemeWhiteOnBlack];
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
}

#pragma mark - View Properties

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Actions

- (IBAction)backButton:(id)sender {
    // Close nowplaying view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"idupnextpopover"]){
        UIPopoverController* popOverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        [(MSPUpNextViewController*)[segue destinationViewController] setParentPopover:popOverController];
    }
    
}

@end
