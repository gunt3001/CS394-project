//
//  MSPPlayerViewController.m
//  Meso
//
//  Created by Gun on 10/4/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//  An abstract class for any view requiring media player controls
//

#import "MSPPlayerViewController.h"
#import "MSPMediaPlayerHelper.h"
#import "MSPConstants.h"
#import "MSPStringHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface MSPPlayerViewController ()


@end

@implementation MSPPlayerViewController{
    
    // Dummy UI Elements
    UIView*         _labelSongTitleGuide;          // Display area of Song Title Label
    UIView*         _labelSongSubtitleGuide;       // Display area of Song Subtitle Label
    CGFloat         _labelSongSubtitleFontSize;    // Font size for subtitle label
    UIToolbar*      _toolbarBackground;            // Toolbar to blur background image
    
    // Flags
    BOOL            _isShowingAltTitle;            // Whether the song name shown is the alternate title
    BOOL            _isShowingLyrics;              // Whether the lyrics is currently shown

    // Other objects
    MPMusicPlayerController* _musicPlayer;         // The iPod music player
    NSString*       _displayedSongTitle;           // Title of song on display
    NSString*       _displayedSongAltTitle;        // Alternate title of song on display
    NSNumber*       _displayedSongPID;             // PID of song on display
    
    // Timers
    NSTimer*        _elapsedTimer;                 // Timer used to update elapsed time and progress bars
    NSTimer*        _fastSeekTimer;                // Timer to use for delay before fast seeking
    
    // Gesture Recognizers
    UITapGestureRecognizer* _tapToViewAltTitle;     // Tap on title area to reveal alternate song title
    UITapGestureRecognizer* _tapToShowLyrics;       // Tap on lyrics (artwork) area to toggle lyrics

}

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do One-time setup of UI Elements
    
    [self setupLabels];                               // Title and Subtitle Related
    [self setupArtwork];                              // Artwork Related
    [self setupLyrics];                               // Lyrics Related
    [self setupButtons];                              // Buttons Related
    [self setupSliders];                              // Sliders Related
    
    // Get reference to the music player
    _musicPlayer   = [MSPMediaPlayerHelper sharedPlayer];

}

#pragma mark Related Methods

- (void) setupLabels{
    
    // Create dummy UIViews to guide frames of MarqueeLabel
    //
    // same frame as the text labels
    _labelSongTitleGuide = [[UIView alloc] initWithFrame:[_labelSongTitle frame]];
    _labelSongSubtitleGuide = [[UIView alloc] initWithFrame:[_labelSongSubtitle frame]];
    //
    // and same resizing method
    [_labelSongTitleGuide setAutoresizingMask:[_labelSongSubtitle autoresizingMask]];
    [_labelSongSubtitleGuide setAutoresizingMask:[_labelSongSubtitle autoresizingMask]];
    //
    // Insert them to view
    [self.view addSubview:_labelSongTitleGuide];
    [self.view addSubview:_labelSongSubtitleGuide];
    
    _labelSongSubtitleFontSize = _labelSongSubtitle.font.pointSize;
    
    // Setup "tap to show alternate title" gesture
    _isShowingAltTitle = NO;
    _tapToViewAltTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAltTitle:)];
    [_tapToViewAltTitle setNumberOfTapsRequired:1];
    [_tapToViewAltTitle setDelegate:self];
    [self.view addGestureRecognizer:_tapToViewAltTitle];
}

- (void) setupArtwork{
    
    // Use imagescroller to allow song skipping by swiping
    // If one doesn't exist, don't do the setup
    if (_imageScroller) {
        // Set delegate
        [_imageScroller setDelegate:self];
        
        // Disable tap to go to top, since there's nothing to go up anyway
        // This is to enable the functionality in any subview that needs it
        [_imageScroller setScrollsToTop:NO];
        
        [self updateImageScroller];
    }
    
    // Use toolbar trick to blur background
    if (_imageArtworkBack && !_toolbarBackground){
        _toolbarBackground = [[UIToolbar alloc] init];
        [_toolbarBackground setBarStyle:UIBarStyleBlack];
        [self.view insertSubview:_toolbarBackground aboveSubview:_imageArtworkBack];
        [_toolbarBackground setFrame:self.view.frame];
        [_toolbarBackground setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
    
    //Set proper resizing mode for button artwork
    [[_imageArtworkButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
}

- (void) setupLyrics{
    
    // Setup "tap to show lyrics" gesture
    _isShowingLyrics = NO;
    _tapToShowLyrics = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyrics:)];
    [_tapToShowLyrics setNumberOfTapsRequired:1];
    [_tapToShowLyrics setDelegate:self];
    [self.view addGestureRecognizer:_tapToShowLyrics];

}

- (void) setupButtons{
    
    // Play-Pause button
    [_buttonPlayPause addTarget:self action:@selector(buttonPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    
    // Forward Skip Button
    [_buttonForward addTarget:self action:@selector(buttonForwardTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonForward addTarget:self action:@selector(buttonForwardTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_buttonForward addTarget:self action:@selector(buttonForwardTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    // Backward Skip Button
    [_buttonBackward addTarget:self action:@selector(buttonBackwardTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonBackward addTarget:self action:@selector(buttonBackwardTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_buttonBackward addTarget:self action:@selector(buttonBackwardTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    // Shuffle & Repeat Button
    [_buttonShuffle addTarget:self action:@selector(buttonShuffle:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonRepeat addTarget:self action:@selector(buttonRepeat:) forControlEvents:UIControlEventTouchUpInside];
    
    // Seek bar slider
    [_sliderProgress addTarget:self action:@selector(sliderBarValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) setupSliders{
    
    // Change colors for progress bar
    switch (_colorScheme) {
        case MSPColorSchemeWhiteOnBlack:
            [_sliderProgress setThumbImage:[UIImage imageNamed:@"ProgressSliderThumb"] forState:UIControlStateNormal];
            break;
            
        case MSPColorSchemeDefault:
        default:
            [_sliderProgress setThumbImage:[UIImage imageNamed:@"ProgressSliderThumbBlack"] forState:UIControlStateNormal];
            break;
    }
    
    // Configure VolumeView styles
    // Change thumb image
    [_sliderVolume setVolumeThumbImage:[UIImage imageNamed:@"VolumeSliderThumb"] forState:UIControlStateNormal];
    // Remove the route button to follow design style of built-in music player
    // To change route, use iOS' control center
    [_sliderVolume setShowsRouteButton:NO];
    
}

#pragma mark - View Changes

// View Will Appear
// Things to do every time the view with the controls appear on the screen
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Force the update of view's bounds
    // A bug in iOS causes it not to be updated the first time app starts up
    // check if bounds is currently in portrait mode, but the view is in landscape
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
        && self.view.bounds.size.width < self.view.bounds.size.height){
        
        // Swap height and width
        CGRect originalBounds = self.view.bounds;
        [self.view setBounds:CGRectMake(originalBounds.origin.x,
                                    originalBounds.origin.y,
                                    originalBounds.size.height,
                                    originalBounds.size.width)];
    }
    
    [self setupMediaUpdate];                // Subscribe to media status changes
    [self updateMediaData];                 // Update now playing item
    [self setupTimer];                      // Set up timer to keep track of elapsed time
    [self updateImageScroller];             // Update scrollview bounds
    [self recreateMarqueeTexts];            // Update labels' bounds
}

// View Did Appear
// Things to do every time the view with the controls appear on the screen
// But can only be done when the view has already appeared
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Restart marquee animations
    [_labelSongTitle restartLabel];
    [_labelSongSubtitle restartLabel];
}

// View Did Disappear
// Things to do when the view is going out of user's view
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // Unsubscribe to media status changes
    [self unsetMediaUpdate];
    
    // Unset timer
    [_elapsedTimer invalidate];
}

// Do some preparartion for screen rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Before changing orientation
    
    // We're replacing the marquee text with new object
    // Hide it so the transition is smoother
    [UIView animateWithDuration:0.1 animations:^{
        [_labelSongTitle setAlpha:0.0];
        [_labelSongSubtitle setAlpha:0.0];
    }];
    
    // Change imagescroller to one page when rotating to smooth rotation
    if (_imageScroller) {
        // Set content size to one page
        [_imageScroller setContentSize:_imageScroller.bounds.size];
        
        // Move the artwork to that page
        CGFloat width = _imageScroller.bounds.size.width;
        CGRect rect = _imageArtwork.frame;
        rect.origin.x -= width;
        [_imageArtwork setFrame:rect];
    }
}

// Things to do after rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // Update the image scroller size
    [self updateImageScroller];
    
    // Set up new marquee text
    [self recreateMarqueeTexts];
}

#pragma mark Related Methods

- (void)setupTimer{
    
    // Update at a constant time
    _elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:NOWPLAYING_UPDATE_INTERVAL
                                                     target:self
                                                   selector:@selector(updateElapsedTime)
                                                   userInfo:nil repeats:YES];
}

- (void)setupMediaUpdate{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // Add observers
    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:_musicPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(handlePlaybackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:_musicPlayer];
    
}

- (void)unsetMediaUpdate{
    
    // Remove observers
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:_musicPlayer];
    [notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:_musicPlayer];
    
}

#pragma mark - Gesture Actions & Delegates

// Action when scroller page has changed (user has swiped the album art image)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    // If we swiped right, skip to previous song
    if (page == 0){
        [_musicPlayer skipToPreviousItem];
    }
    // Swiping left, skip to next song
    else if (page == 2){
        [_musicPlayer skipToNextItem];
    }
    
    // If we changed track, smooth the transition to next art
    if (page == 0 || page == 2){
        // Hide art
        [_imageArtwork setImage:nil];
        
        // Reset back to page 1
        [_imageScroller setContentOffset:CGPointMake([_imageScroller frame].size.width, 0.0)];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Check what gesture are we detecting
    if (gestureRecognizer == _tapToShowLyrics){
        CGPoint touchLocation = [touch locationInView:_lyricsView];
        return CGRectContainsPoint(_lyricsTextView.frame, touchLocation);
    }
    else if (gestureRecognizer == _tapToViewAltTitle){
        CGPoint touchLocation = [touch locationInView:[gestureRecognizer view]];
        return CGRectContainsPoint(_altTitleTapArea.frame, touchLocation);
    }
    
    // Otherwise
    return NO;    
}

- (void)showAltTitle:(UITapGestureRecognizer*) sender{
    // Show alternate song title
    
    // Prepare to animate text change
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.2;
    [_labelSongTitle.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    if (_isShowingAltTitle){
        [_labelSongTitle setText:_displayedSongTitle];
        _isShowingAltTitle = NO;
    }
    else {
        [_labelSongTitle setText:_displayedSongAltTitle];
        _isShowingAltTitle = YES;
    }
    
}

- (void)showLyrics:(UITapGestureRecognizer*) sender{
    // Show additional controls and lyrics
    
    if (_isShowingLyrics){
        [UIView transitionWithView:_lyricsView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_lyricsView setHidden:YES];
                        }
                        completion:NULL];
        
        [UIView transitionWithView:self.imageScroller
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.imageScroller setHidden:NO];
                        }
                        completion:NULL];
        
        _isShowingLyrics = NO;
    }
    else {
        [UIView transitionWithView:_lyricsView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_lyricsView setHidden:NO];
                        }
                        completion:NULL];
        
        [UIView transitionWithView:self.imageScroller
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.imageScroller setHidden:YES];
                        }
                        completion:NULL];
        
        _isShowingLyrics = YES;
    }
    
}

#pragma mark - Buttons Actions

- (void)buttonPlayPause:(id)sender {
    // Pause if playing, play if paused
    
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePaused){
        [_musicPlayer pause];    // Pause once before playing to fix when state would get occasionally stuck at paused
        [_musicPlayer play];
    }
    else if ([_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [_musicPlayer play];
        
        [self updateMediaData];
    }
    else if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [_musicPlayer pause];
    }
}

- (void)buttonForwardTouchUpInside:(id)sender {
    // Skip to next song, or stop fast forwarding
    
    // Stop timer when we touched down
    if (_fastSeekTimer){
        [_fastSeekTimer invalidate];
        _fastSeekTimer = nil;
    }
    
    // If we're fast forwarding, stop it and don't skip to next song
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [_musicPlayer currentPlaybackRate] != 1.0){
        [_musicPlayer setCurrentPlaybackRate:1.0];
    }
    // Otherwise we're skipping to next song
    else{
        [_musicPlayer skipToNextItem];
    }
    
}

- (void)buttonForwardTouchDragExit:(id)sender {
    // When buttton is dragged outside
    // Invalidate timer when touched down
    
    // Stop timer when we touched down
    if (_fastSeekTimer){
        [_fastSeekTimer invalidate];
        _fastSeekTimer = nil;
    }
    // Stop any fast forwarding
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [_musicPlayer currentPlaybackRate] != 1.0){
        [_musicPlayer setCurrentPlaybackRate:1.0];
    }
}

- (void)buttonForwardTouchDown:(id)sender {
    // When forward button is touched
    // Start a new timer
    // If button is not lifted within a certain time, start fast forwarding
    
    _fastSeekTimer = [NSTimer scheduledTimerWithTimeInterval:FAST_SEEKING_DELAY
                                                      target:self
                                                    selector:@selector(fastForward)
                                                    userInfo:nil repeats:NO];
}

- (void)buttonBackwardTouchUpInside:(id)sender {
    // Skip to beginning, or to previous song if at less than certain seconds
    
    // Stop timer when we touched down
    if (_fastSeekTimer){
        [_fastSeekTimer invalidate];
        _fastSeekTimer = nil;
    }
    
    // If we're fast forwarding, stop it and don't skip
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [_musicPlayer currentPlaybackRate] != 1.0){
        [_musicPlayer setCurrentPlaybackRate:1.0];
    }
    // Otherwise we're doing skipping logic
    else{
        if ([_musicPlayer currentPlaybackTime] <= 3.0){
            [_musicPlayer skipToPreviousItem];
        }
        else{
            [_musicPlayer skipToBeginning];
        }
    }
}

- (void)buttonBackwardTouchDragExit:(id)sender {
    // When buttton is dragged outside
    // Invalidate timer when touched down
    
    // Stop timer when we touched down
    if (_fastSeekTimer){
        [_fastSeekTimer invalidate];
        _fastSeekTimer = nil;
    }
    // Stop any fast forwarding
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [_musicPlayer currentPlaybackRate] != 1.0){
        [_musicPlayer setCurrentPlaybackRate:1.0];
    }
}

- (void)buttonBackwardTouchDown:(id)sender {
    // When backward button is touched
    // Start a new timer
    // If button is not lifted within a certain time, start fast seeking backwards
    
    _fastSeekTimer = [NSTimer scheduledTimerWithTimeInterval:FAST_SEEKING_DELAY
                                                      target:self
                                                    selector:@selector(fastBackward)
                                                    userInfo:nil repeats:NO];
}

- (void)buttonShuffle:(id)sender {
    // Toggle between shuffle states
    
    MPMusicShuffleMode shuffleMode = [_musicPlayer shuffleMode];
    
    if (shuffleMode == MPMusicShuffleModeOff){              // Shuffle off
        [_musicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    }
    else{                                                   // Shuffle on
        [_musicPlayer setShuffleMode:MPMusicShuffleModeOff];
    }
    
    [self updateButtonsState];
}

- (void)buttonRepeat:(id)sender {
    // Toggle between repeat states
    
    MPMusicRepeatMode repeatMode = [_musicPlayer repeatMode];
    
    if (repeatMode == MPMusicRepeatModeOne){            // Repeat one
        [_musicPlayer setRepeatMode:MPMusicRepeatModeAll];
    }
    else if (repeatMode == MPMusicRepeatModeNone){      // Repeat off
        [_musicPlayer setRepeatMode:MPMusicRepeatModeOne];
    }
    else{                                               // Repeat all or default
        [_musicPlayer setRepeatMode:MPMusicRepeatModeNone];
    }
    
    [self updateButtonsState];
}

- (void)sliderBarValueChanged:(id)sender {
    
    if ([_sliderProgress isTracking]){
        NSTimeInterval totalTime = [[[_musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        [_musicPlayer setCurrentPlaybackTime:[_sliderProgress value] * totalTime];
    }
}

#pragma mark Releated methods to be called by timer

// Start fast forwarding
- (void) fastForward{
    [_musicPlayer setCurrentPlaybackRate:FAST_SEEKING_RATE];
}

// Start fast seeking backwards
- (void) fastBackward{
    [_musicPlayer setCurrentPlaybackRate:FAST_SEEKING_RATE * -1];
}

#pragma mark - Updating UI

// Refresh the media data from player to the view
- (void) updateMediaData{
    
    // Reset flags
    _isShowingAltTitle = NO;
    
    // Update UI Elements that are independent of now playing song
    [self updateButtonsState];
    [self updateElapsedTime];
    
    // Check if we're playing anything at all
    if ([_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        
        // Title & Subtitle
        [_labelSongTitle setText:STRING_NOTHING_PLAYING];
        [_labelSongSubtitle setText:@""];
        
        // Artworks
        [self changeImageWithTransitionOn:_imageArtwork withImage:nil];
        [self changeImageWithTransitionOn:_imageArtworkButton withImage:nil];
        if (_imageArtworkBack)
            [self changeImageWithTransitionOn:_imageArtworkBack withImage:nil];
        
        // Timers
        [_labelTotalTime setText:STRING_NOTHING_PLAYING_TIME];
        
        // Metadata
        _displayedSongTitle = STRING_NOTHING_PLAYING;
        _displayedSongAltTitle = STRING_NOTHING_PLAYING;
        _displayedSongPID = nil;
        return;
    }
    
    // Get the playing song's PID
    MPMediaItem* nowPlaying = [_musicPlayer nowPlayingItem];
    NSNumber* songPid = [nowPlaying valueForProperty:MPMediaItemPropertyPersistentID];
    
    // Check if we're playing the same song
    // Skip the update to improve performance
    if (_displayedSongPID && [_displayedSongPID isEqualToNumber:songPid]){
        return;
    }
    
    // Otherwise grab necessary information
    NSString* title = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
    NSString* album = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString* artist = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
    NSAttributedString* subtitle =  [MSPStringHelper getAttributedSubtitleFromArtist:artist
                                                                                  Album:album
                                                                           WithFontSize:_labelSongSubtitleFontSize
                                                                                  Color:[_labelSongSubtitle textColor]];
    
    MPMediaItemArtwork* art = [nowPlaying valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [art imageWithSize:[_imageArtwork frame].size];
    if (!artworkImage) artworkImage = [UIImage imageNamed:@"noartplaceholder"];
    NSString* altTitle = [nowPlaying valueForProperty:MSPMediaItemPropertySortTitle];
    NSTimeInterval totalTime = [[nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString* totalString = [MSPStringHelper getTimeStringFromInterval:totalTime];
    // A bug in API causes Lyrics to not load properly using regular methods
    // Following is a workaround
    NSURL* songURL = [nowPlaying valueForProperty:MPMediaItemPropertyAssetURL];
    AVAsset* songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    NSString* lyrics = [songAsset lyrics];
    
    // Display them
    [_labelSongTitle setText:title];                                                // Title
    [_labelSongSubtitle setAttributedText:subtitle];                                // Subtitle
    [self recreateMarqueeTexts];                                                    // Update bounds for Title/Subtitle
    [self changeImageWithTransitionOn:_imageArtwork withImage:artworkImage];        // Artwork
    [self changeImageWithTransitionOn:_imageArtworkButton withImage:artworkImage];  // Artwork Button
    if (_imageArtworkBack)
        [self changeImageWithTransitionOn:_imageArtworkBack withImage:artworkImage];// Background Artwork
    [_labelTotalTime setText:totalString];                                          // Total time
    [self setLyricsText:lyrics];                                                    // Lyrics
    
    // Metadata
    _displayedSongTitle = title;                                        // Title, used to switch with alternate title
    _displayedSongAltTitle = altTitle;                                  // Alternate title
    _displayedSongPID = songPid;                                        // Persistent ID
}

// Update the elapsed time label and the progress bar
- (void)updateElapsedTime{
    
    NSTimeInterval elapsedTime = [_musicPlayer currentPlaybackTime];
    MPMediaItem* nowPlaying = [_musicPlayer nowPlayingItem];
    NSTimeInterval nowPlayingSongTotalTime = [[nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    
    // Check if the music player is stopped
    if ([_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        // Set elapsed time to nothing
        [_labelElapsedTime setText:STRING_NOTHING_PLAYING_TIME];
        
        // Set progress to 0
        [_sliderProgress setValue:0.0];
    }
    else{
        NSString* elapsedString = [MSPStringHelper getTimeStringFromInterval:elapsedTime];
        [_labelElapsedTime setText:elapsedString];
        
        float progress = elapsedTime / nowPlayingSongTotalTime;
        [_sliderProgress setValue:progress];
    }
}

- (void)updateButtonsState{
    // Update button state for shuffle, repeat, and play-pause buttons
    
    MPMusicShuffleMode shuffleMode = [_musicPlayer shuffleMode];
    MPMusicRepeatMode repeatMode = [_musicPlayer repeatMode];
    
    UIColor* offColor;
    UIColor* onColor;
    
    switch (_colorScheme) {
        case MSPColorSchemeWhiteOnBlack:
            offColor = [UIColor blackColor];
            onColor = [UIColor whiteColor];
            break;
            
        case MSPColorSchemeDefault:
        default:
            offColor = [UIColor blackColor];
            onColor = [self.view tintColor];
            break;
    }
    
    if (shuffleMode == MPMusicShuffleModeOff){              // Shuffle off
        [_buttonShuffle setTintColor:offColor];
    }
    else{                                                   // Shuffle on
        [_buttonShuffle setTintColor:onColor];
    }
    
    if (repeatMode == MPMusicRepeatModeOne){            // Repeat one
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeatone"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:onColor];
    }
    else if (repeatMode == MPMusicRepeatModeNone){      // Repeat off
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:offColor];
    }
    else{                                               // Repeat all or default
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:onColor];
    }
    
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePaused ||
        [_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [_buttonPlayPause setImage:[UIImage imageNamed:@"FillButtonPlay"] forState:UIControlStateNormal];
    }
    else if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [_buttonPlayPause setImage:[UIImage imageNamed:@"FillButtonPause"] forState:UIControlStateNormal];
    }
}

- (void)handleNowPlayingItemChanged:(id)notification {
    // When the playing item changed, update the media data
    [self updateMediaData];
}

- (void)handlePlaybackStateChanged:(id)notification {
    // When playback state changed, update the following
    
    [self updateButtonsState];              // Play/Pause/Shuffle/Repeat Buttons state
    [self updateElapsedTime];               // Playback Time
}

- (void) changeImageWithTransitionOn:(UIView*)view withImage:(UIImage*)image{
    // Change image in the given view with fading animation
    // Supports UIImageView* and UIButton*
    
    if (!view) return;
    
    [UIView transitionWithView:view
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if ([view isKindOfClass:[UIButton class]]){
                            [(UIButton*)view setImage:image forState:UIControlStateNormal];
                        }
                        else if ([view isKindOfClass:[UIImageView class]]){
                            [(UIImageView*)view setImage:image];
                        }
                        else{
                            NSLog(@"WARNING: Changing image on incompatible view");
                        }
                    } completion:NULL];
}

- (void) recreateMarqueeTexts{
    // Update the frame for Song title and subtitle by creating new MarqueeLabel object
    
    MarqueeLabel* newTitle = [[MarqueeLabel alloc] initWithFrame:_labelSongTitleGuide.frame];
    MarqueeLabel* newSubtitle = [[MarqueeLabel alloc] initWithFrame:_labelSongSubtitleGuide.frame];
    
    // Use original text & styles
    [newTitle setText:[_labelSongTitle text]];
    [newTitle setFont:[_labelSongTitle font]];
    [newTitle setTextAlignment:[_labelSongTitle textAlignment]];
    [newSubtitle setTextAlignment:[_labelSongSubtitle textAlignment]];
    [newSubtitle setAttributedText:[_labelSongSubtitle attributedText]];
    NSInteger titleIndex = [[self.view subviews] indexOfObject:_labelSongTitle];
    NSInteger subtitleIndex = [[self.view subviews] indexOfObject:_labelSongSubtitle];
    
    UIColor* textColor;
    switch (_colorScheme) {
        case MSPColorSchemeWhiteOnBlack:
            textColor = [UIColor whiteColor];
            break;
            
        case MSPColorSchemeDefault:
        default:
            textColor = [UIColor blackColor];
            break;
    }
    
    // Set up the properties
    [newTitle setTextColor:textColor];                 // Color
    [newTitle setRate:MARQUEE_LABEL_RATE];             // Speed
    [newTitle setFadeLength:10.0];                     // Fade size
    [newTitle setAnimationDelay:3.0];                  // Pause
    
    [newSubtitle setTextColor:textColor];                 // Color
    [newSubtitle setRate:MARQUEE_LABEL_RATE];             // Speed
    [newSubtitle setFadeLength:10.0];                     // Fade size
    [newSubtitle setAnimationDelay:3.0];                  // Pause
    
    // Remove old label from superview
    [_labelSongTitle removeFromSuperview];
    [_labelSongSubtitle removeFromSuperview];
    _labelSongTitle = nil;
    _labelSongSubtitle = nil;
    
    // Replace the pointer (outlet) in this controller with the new stuff
    _labelSongTitle = newTitle;
    _labelSongSubtitle = newSubtitle;
    
    // Hide before adding to view
    [newTitle setAlpha:0.0];
    [newSubtitle setAlpha:0.0];
    
    // Add to view
    [self.view insertSubview:newTitle atIndex:titleIndex];
    [self.view insertSubview:newSubtitle atIndex:subtitleIndex];
    
    // Show with animation
    [UIView animateWithDuration:0.1 animations:^{
        [_labelSongTitle setAlpha:1.0];
        [_labelSongSubtitle setAlpha:1.0];
    }];
}

- (void) updateImageScroller{
    // Update the bounds of album art scroller
    
    // If one doesn't exist, don't do the update
    if (_imageScroller) {
        
        // Content is 3x screen size to allow swiping left and right
        [_imageScroller setContentSize:CGSizeMake([_imageScroller frame].size.width * 3.0,
                                                  [_imageScroller frame].size.height)];
        // Move the art image to the center
        CGFloat xOffsetToCenter = ([_imageScroller frame].size.width - [_imageArtwork frame].size.width) / 2;
        [_imageArtwork setFrame:CGRectMake(xOffsetToCenter + [_imageScroller frame].size.width,
                                           [_imageArtwork frame].origin.y,
                                           [_imageArtwork frame].size.width,
                                           [_imageArtwork frame].size.height)];
        
        // Set new origins to follow
        [_imageScroller setContentOffset:CGPointMake([_imageScroller frame].size.width, 0.0)];
    }
}

- (void) setLyricsText:(NSString*) lyrics{
    
    if (!lyrics) lyrics = @"No Lyrics";
    
    // A Bug (sigh... Apple!!!) causes text attributes to be reset every text change
    // Workaround by setting selectable to NO
    
    [_lyricsTextView setSelectable:YES];
    
    [_lyricsTextView setText:lyrics];
    
    [_lyricsTextView setSelectable:NO];
}

@end
