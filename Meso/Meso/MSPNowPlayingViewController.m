//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"

@interface MSPNowPlayingViewController ()

@end

@implementation MSPNowPlayingViewController{
    UIViewController*            menuViewController;
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Set color scheme
    [self setColorScheme:MSPColorSchemeWhiteOnBlack];
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    
    // Initialize the menu view controller to nil
    menuViewController = nil;
}

#pragma mark - View Properties

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (menuViewController) return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Actions
- (IBAction)backButton:(id)sender {
    // Close nowplaying view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)menuButton:(id)sender {
    // Show menu as a subview
    // Warning: Only link this to the iPhone storyboard
    // Use normal popover for iPad Storyboard
    
    // Don't show if already shown
    if (menuViewController) return;
    [self showMenu];
}

#pragma mark - Showing Up-Next Menu

- (void)showMenu{
    // Show menu as a subview
    
    // Create the controller and add it to the hierarchy
    menuViewController= [[self storyboard] instantiateViewControllerWithIdentifier:@"idupnextview"];
    [self addChildViewController:menuViewController];
    
    // Add subview below the screen
    CGRect newFrame = [menuViewController view].frame;
    newFrame.origin.y = newFrame.size.height;
    [menuViewController.view setFrame:newFrame];
    [self.view addSubview:menuViewController.view];
    
    // Transition it up
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [menuViewController.view setFrame:self.view.frame];
    } completion:^(BOOL finished) {
        if (finished){
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }];
}

- (void)hideMenu{
    // Close upnext view
    
    // Before transitioning, update status bar back
    UIViewController* menuViewControllerTemp = menuViewController;
    menuViewController = nil;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Transition away
    CGRect newFrame = menuViewControllerTemp.view.frame;
    newFrame.origin.y = newFrame.size.height;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [menuViewControllerTemp.view setFrame:newFrame];
    } completion:^(BOOL finished) {
        if (finished){
            // Remove from appropriate view/viewcontroller
            [menuViewControllerTemp.view removeFromSuperview];
            [menuViewControllerTemp removeFromParentViewController];
            
        }
    }];
}

@end
