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
#import "MarqueeLabel.h"

@interface MSPPlayerController : NSObject <UIGestureRecognizerDelegate, UIScrollViewDelegate>

/**
 Initialize with the given UI Elements and Properties
 imageArtwork only supports UIButton or UIImageView.
 */
- (id)initWithView:(UIView*)view
             Title:(MarqueeLabel*)labelSongTitle
          Subtitle:(MarqueeLabel*)labelSongSubtitle
         Textcolor:(UIColor*)textColor
  SubtitleFontSize:(CGFloat)subtitleFontSize
   AltTitleTapArea:(UIView*)altTitleTapArea
      ArtworkImage:(id)imageArtwork
    WithDropShadow:(BOOL)withDropShadow
   BackgroundImage:(UIImageView*)imageArtworkBack
        ScrollView:(UIScrollView*)imageScroller
           Seekbar:(UISlider*)sliderBar
        ThumbImage:(UIImage*)thumbImage
   PlayPauseButton:(UIButton*)buttonPlayPause
     ForwardButton:(UIButton*)buttonForward
    BackwardButton:(UIButton*)buttonBackward
     ShuffleButton:(UIButton*)buttonShuffle
      RepeatButton:(UIButton*)buttonRepeat
          OffColor:(UIColor*)offColor
       ElapsedTime:(UILabel*)labelElapsedTime
         TotalTime:(UILabel*)labelTotalTime
         TintColor:(UIColor*)tintColor;

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
