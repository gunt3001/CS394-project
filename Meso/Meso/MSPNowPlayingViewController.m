//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"
#import "MarqueeLabel.h"
#import "MSPMediaPlayerViewHelper.h"
#import <MediaPlayer/MediaPlayer.h>         // For VolumeView

@interface MSPNowPlayingViewController ()

@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtworkBack;
@property (weak, nonatomic) IBOutlet UISlider *sliderBar;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroller;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *buttonForward;
@property (weak, nonatomic) IBOutlet UIButton *buttonBackward;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (weak, nonatomic) IBOutlet UIButton *buttonRepeat;
@property (weak, nonatomic) IBOutlet UILabel *labelElapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UIView *altTitleTapArea;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;

@end

@implementation MSPNowPlayingViewController{
    MSPMediaPlayerViewHelper*    playerController;
    UIViewController*            menuViewController;
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the player controller object
    playerController = [[MSPMediaPlayerViewHelper alloc] initWithView:[self view]
                                                           Title:_labelSongTitle
                                                        Subtitle:_labelSongSubtitle
                                                SubtitleFontSize:[[_labelSongSubtitle font] pointSize]
                                                 AltTitleTapArea:_altTitleTapArea
                                                    ArtworkImage:_imageArtwork
                                                 BackgroundImage:_imageArtworkBack
                                                   ArtworkButton:nil
                                                      ScrollView:_imageScroller
                                                         Seekbar:_sliderBar
                                                 PlayPauseButton:_buttonPlayPause
                                                   ForwardButton:_buttonForward
                                                  BackwardButton:_buttonBackward
                                                   ShuffleButton:_buttonShuffle
                                                    RepeatButton:_buttonRepeat
                                                     ElapsedTime:_labelElapsedTime
                                                       TotalTime:_labelTotalTime
                                                    VolumeSlider:_volumeView
                                                     ColorScheme:MSPColorSchemeWhiteOnBlack];
    
    // Remove the route button to follow design style of built-in music player
    // To change route, use iOS' control center
    [_volumeView setShowsRouteButton:NO];
    
    // Initialize the menu view controller to nil
    menuViewController = nil;
}

#pragma mark - View Changes

// View Will Appear
// Things to do every time the view with the controls appear on the screen
- (void)viewWillAppear:(BOOL)animated{
    
    [playerController viewWillAppear];
    [super viewWillAppear:animated];
}

// View Did Appear
// Things to do every time the view with the controls appear on the screen
// But can only be done when the view has already appeared
- (void) viewDidAppear:(BOOL)animated{
    [playerController viewDidAppear];
    [super viewDidAppear:animated];
}

// View Did Disappear
// Things to do when the view is going out of user's view
- (void) viewDidDisappear:(BOOL)animated{
    [playerController viewDidDisappear];
    [super viewWillDisappear:animated];
}

// Do some preparartion for screen rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [playerController willRotateToInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

// Things to do after rotation
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [playerController didRotateFromInterfaceOrientation];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
