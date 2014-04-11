//
//  MSPSharedPlayer.h
//  Meso
//
//  Created by Gun on 24/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//  MSPSharedPlayer takes care of controlling the music player
//  and updating related UI Elements
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MarqueeLabel.h"

typedef NS_ENUM(NSInteger, MSPColorScheme) {
    MSPColorSchemeDefault,
    MSPColorSchemeWhiteOnBlack
};

@interface MSPMediaPlayerViewHelper : NSObject <UIGestureRecognizerDelegate, UIScrollViewDelegate>

/**
 Initialize with the given UI Elements and Properties
 imageArtwork only supports UIButton or UIImageView.
 */
- (id)initWithView:(UIView*)view
             Title:(MarqueeLabel*)labelSongTitle
          Subtitle:(MarqueeLabel*)labelSongSubtitle
   AltTitleTapArea:(UIView*)altTitleTapArea
      ArtworkImage:(UIImageView*)imageArtwork
   BackgroundImage:(UIImageView*)imageArtworkBack
     ArtworkButton:(UIButton*)imageArtworkButton
        ScrollView:(UIScrollView*)imageScroller
           Seekbar:(UISlider*)sliderBar
   PlayPauseButton:(UIButton*)buttonPlayPause
     ForwardButton:(UIButton*)buttonForward
    BackwardButton:(UIButton*)buttonBackward
     ShuffleButton:(UIButton*)buttonShuffle
      RepeatButton:(UIButton*)buttonRepeat
       ElapsedTime:(UILabel*)labelElapsedTime
         TotalTime:(UILabel*)labelTotalTime
      VolumeSlider:(MPVolumeView*)sliderVolume
       ColorScheme:(MSPColorScheme)colorScheme;

/// Things to do every time the view with the controls appear on the screen
- (void) viewWillAppear;

/// Things to do every time the view with the controls appear on the screen
/// But can only be done when the view has already appeared
- (void) viewDidAppear;

/// Things to do when the view is going out of user's view
- (void) viewDidDisappear;

/// Do some preparartion for screen rotation
- (void) willRotateToInterfaceOrientation;

/// Things to do after screen rotation
- (void) didRotateFromInterfaceOrientation;

@end
