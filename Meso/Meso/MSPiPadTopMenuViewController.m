//
//  MSPiPadTopMenuViewController.m
//  Meso
//
//  Created by Gun on 23/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPiPadTopMenuViewController.h"
#import "MarqueeLabel.h"
#import "MSPPlayerController.h"

@interface MSPiPadTopMenuViewController ()

@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;
@property (weak, nonatomic) IBOutlet UISlider *sliderBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *buttonForward;
@property (weak, nonatomic) IBOutlet UIButton *buttonBackward;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (weak, nonatomic) IBOutlet UIButton *buttonRepeat;
@property (weak, nonatomic) IBOutlet UILabel *labelElapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UIView *altTitleTapArea;

@end

@implementation MSPiPadTopMenuViewController{
    MSPPlayerController*    playerController;
}

#pragma mark - Xcode Generated
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the player controller object
    playerController = [[MSPPlayerController alloc] initWithView:[self view]
                                                           Title:_labelSongTitle
                                                        Subtitle:_labelSongSubtitle
                                                       Textcolor:[UIColor blackColor]
                                                 AltTitleTapArea:_altTitleTapArea
                                                    ArtworkImage:_imageArtwork
                                                  WithDropShadow:NO
                                                 BackgroundImage:nil
                                                      ScrollView:nil
                                                         Seekbar:_sliderBar
                                                      ThumbImage:[UIImage imageNamed:@"ProgressSliderThumb"]
                                                 PlayPauseButton:_buttonPlayPause
                                                   ForwardButton:_buttonForward
                                                  BackwardButton:_buttonBackward
                                                   ShuffleButton:_buttonShuffle
                                                    RepeatButton:_buttonRepeat
                                                        OffColor:[UIColor blackColor]
                                                     ElapsedTime:_labelElapsedTime
                                                       TotalTime:_labelTotalTime
                                                       TintColor:[[self view] tintColor]];
    
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

@end
