//
//  MSPiPadTopMenuViewController.m
//  Meso
//
//  Created by Gun on 23/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPiPadTopMenuViewController.h"
#import "MSPUpNextViewController.h"

@interface MSPiPadTopMenuViewController ()

@end

@implementation MSPiPadTopMenuViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Set color scheme
    [self setColorScheme:MSPColorSchemeDefault];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"idupnextpopover"]){
        UIPopoverController* popOverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        [(MSPUpNextViewController*)[segue destinationViewController] setParentPopover:popOverController];
    }
    
}

@end
