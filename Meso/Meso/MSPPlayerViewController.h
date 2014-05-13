//
//  MSPPlayerViewController.h
//  Meso
//
//  Created by Gun on 10/4/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MarqueeLabel.h"

typedef NS_ENUM(NSInteger, MSPColorScheme) {
    MSPColorSchemeDefault,
    MSPColorSchemeWhiteOnBlack
};

@interface MSPPlayerViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIView *altTitleTapArea;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtworkBack;
@property (weak, nonatomic) IBOutlet UIButton *imageArtworkButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *buttonForward;
@property (weak, nonatomic) IBOutlet UIButton *buttonBackward;
@property (weak, nonatomic) IBOutlet UIButton *buttonRepeat;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (weak, nonatomic) IBOutlet MPVolumeView *sliderVolume;
@property (weak, nonatomic) IBOutlet UILabel *labelElapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroller;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;
@property (weak, nonatomic) IBOutlet UIView *lyricsView;
@property (weak, nonatomic) IBOutlet UITextView *lyricsTextView;

@property (nonatomic) MSPColorScheme colorScheme;

@end
