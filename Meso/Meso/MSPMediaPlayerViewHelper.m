//
//  MSPSharedPlayer.m
//  Meso
//
//  Created by Gun on 24/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPMediaPlayerViewHelper.h"
#import "MSPConstants.h"
#import "MSPAppDelegate.h"
#import "MSPStringProcessor.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MSPMediaPlayerViewHelper{
    // Private variables
    
    // UI Elements
    __weak UIView*         _view;                         // The View
    __weak MarqueeLabel*   _labelSongTitle;               // Song Title Label
    __weak MarqueeLabel*   _labelSongSubtitle;            // Song Subtitle Label
    __weak id              _imageArtwork;                 // Song Artwork
    __weak UIImageView*    _imageArtworkBack;             // Song Artwork as Background Image
    __weak UISlider*       _sliderBar;                    // Seek Bar
    __weak UIScrollView*   _imageScroller;                // Scrollview containing artwork
    __weak UIButton*       _buttonPlayPause;              // Play-Pause button
    __weak UIButton*       _buttonForward;                // Forward skip button
    __weak UIButton*       _buttonBackward;               // Backward skip button
    __weak UIButton*       _buttonShuffle;                // Shuffle Button
    __weak UIButton*       _buttonRepeat;                 // Repeat Button
    __weak UILabel*        _labelElapsedTime;             // Elapsed Time Label
    __weak UILabel*        _labelTotalTime;               // Total Time Label
    
    // Colors & Fonts
    UIColor*        _textColor;                    // Text color
    UIColor*        _offColor;                     // Off color for shuffle and repeat buttons
    UIColor*        _tintColor;                    // The view's tint color
    CGFloat         _subtitleFontSize;             // Subtitle font size

    // Dummy UI Elements
    __weak UIView*  _altTitleTapArea;              // Tap area for showing alternate title
    UIView*         _labelSongTitleGuide;          // Display area of Song Title Label
    UIView*         _labelSongSubtitleGuide;       // Display area of Song Subtitle Label
    
    // Flags
    BOOL            _isShowingAltTitle;            // Whether the song name shown is the alternate title
    BOOL            _isButtonImageArtwork;         // Whether imageArtwork is a UIButton. UIImageView otherwise.
    
    // Other objects
    MPMusicPlayerController* _musicPlayer;         // The iPod music player
    NSString*       _displayedSongTitle;           // Title of song on display
    NSString*       _displayedSongAltTitle;        // Alternate title of song on display
    NSNumber*       _displayedSongPID;             // PID of song on display
    
    // Background Processing
    dispatch_queue_t    _imageBlurringQueue;       // GCD Queue for iamge blurring
    NSInteger       _blurringQueueCount;           // Counter for things in queue
    
    // Timers
    NSTimer*        _elapsedTimer;                 // Timer used to update elapsed time and progress bars
    NSTimer*        _fastSeekTimer;                // Timer to use for delay before fast seeking
}

#pragma mark - Initialization

// Init
// Shared Player should be created during -viewDidLoad
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
         TintColor:(UIColor*)tintColor
{
    self = [super init];
    if (self){
        // Initialization
        
        // Get Pointers to UIView elements
        _view              = view;
        _labelSongTitle    = labelSongTitle;
        _labelSongSubtitle = labelSongSubtitle;
        _textColor         = textColor;
        _subtitleFontSize  = subtitleFontSize;
        _sliderBar         = sliderBar;
        _imageArtwork      = imageArtwork;
        _imageScroller     = imageScroller;
        _altTitleTapArea   = altTitleTapArea;
        _buttonPlayPause   = buttonPlayPause;
        _buttonForward     = buttonForward;
        _buttonBackward    = buttonBackward;
        _buttonShuffle     = buttonShuffle;
        _buttonRepeat      = buttonRepeat;
        _offColor          = offColor;
        _imageArtworkBack  = imageArtworkBack;
        _labelElapsedTime  = labelElapsedTime;
        _labelTotalTime    = labelTotalTime;
        _tintColor         = tintColor;
        
        // Do One-time setup of UI Elements
        [self setupArtworkType];                          // Determine the type of imageArtwork
        [self setupGuides];                               // Add dummy UIView as guides for frame of Marquee Text Labels
        [self setupActions];                              // Add actions for buttons
        [self setupSongTitleGesture];                     // Enable tapping on song title to show alternate title
        [self setupMarquee];                              // Set up scrolling text
        [self setupProgressSliderWithThumb:thumbImage];   // Seek bar
        [self setupImageScroller];                        // Use imagescroller to allow song skipping by swiping
        if (withDropShadow)
            [self setupImageArtworkDropShadow];           // Add Drop Shadow to Art Image
        
        // Get reference to the music player
        _musicPlayer   = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    }
    return self;
}

#pragma mark Related Methods

- (void) setupArtworkType{
    // Check the type of the target view
    
    // Check if it's UIButton.
    // Assume UIImageView otherwise.
    _isButtonImageArtwork = [_imageArtwork isKindOfClass:[UIButton class]];
    
    // Set image as fit mode
    if (_isButtonImageArtwork) {
        [[(UIButton*)_imageArtwork imageView] setContentMode: UIViewContentModeScaleAspectFit];
    }
}

- (void) setupGuides{
    
    // Create dummy UIViews with same frame as the text labels
    _labelSongTitleGuide = [[UIView alloc] initWithFrame:[_labelSongTitle frame]];
    _labelSongSubtitleGuide = [[UIView alloc] initWithFrame:[_labelSongSubtitle frame]];
    
    // and same resizing method
    [_labelSongTitleGuide setAutoresizingMask:[_labelSongSubtitle autoresizingMask]];
    [_labelSongSubtitleGuide setAutoresizingMask:[_labelSongSubtitle autoresizingMask]];
    
    // Insert them to view
    [_view addSubview:_labelSongTitleGuide];
    [_view addSubview:_labelSongSubtitleGuide];
}

- (void) setupActions{
    
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
    [_sliderBar addTarget:self action:@selector(sliderBarValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) setupImageScroller{
    
    // If one doesn't exist, don't do the setup
    if (!_imageScroller) return;
    
    // Set delegate
    [_imageScroller setDelegate:self];
    
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

- (void) setupImageArtworkDropShadow{

    [[_imageArtwork layer] setShadowColor:[UIColor blackColor].CGColor];
    [[_imageArtwork layer] setShadowOffset:CGSizeMake(0.0, 0.0)];
    [[_imageArtwork layer] setShadowOpacity:1.0];
    [[_imageArtwork layer] setShadowRadius:2.0];
    [_imageArtwork setClipsToBounds:NO];
}

- (void)setupSongTitleGesture{

    _isShowingAltTitle = NO;
    UITapGestureRecognizer* tapToViewAltTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAltTitle:)];
    [tapToViewAltTitle setNumberOfTapsRequired:1];
    [tapToViewAltTitle setDelegate:self];
    [_view addGestureRecognizer:tapToViewAltTitle];
}

- (void) setupProgressSliderWithThumb:(UIImage*)image{
    [_sliderBar setThumbImage:image forState:UIControlStateNormal];
}

- (void) setupMarquee{
    
    // Change the regular label into a marquee one
    [self recreateMarqueeTexts];
    
}

#pragma mark - View Changes

// View Will Appear
// Things to do every time the view with the controls appear on the screen
- (void) viewWillAppear{
    
    // Recreate marquee & scrollview the first time view appears
    // Fix bug where many ui elements' frame has wrong dimensions when starting orientation is not portrait
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        [self recreateMarqueeTexts];
        [self setupImageScroller];
    }
    
    [self setupMediaUpdate];                // Subscribe to media status changes
    [self updateMediaData];                 // Update now playing item
    [self setupTimer];                      // Set up timer to keep track of elapsed time

}

// View Did Appear
// Things to do every time the view with the controls appear on the screen
// But can only be done when the view has already appeared
- (void) viewDidAppear {
    
    // Restart marquee animations
    [_labelSongTitle restartLabel];
    [_labelSongSubtitle restartLabel];
    
}

// View Did Disappear
// Things to do when the view is going out of user's view
- (void) viewDidDisappear {
    
    // Unsubscribe to media status changes
    [self unsetMediaUpdate];
    
    // Unset timer
    [_elapsedTimer invalidate];
}

// Do some preparartion for screen rotation
- (void)willRotateToInterfaceOrientation{
    // Before changing orientation
    
    // We're replacing the marquee text with new object
    // Hide it so the transition is smoother
    [UIView animateWithDuration:0.1 animations:^{
        [_labelSongTitle setAlpha:0.0];
        [_labelSongSubtitle setAlpha:0.0];
    }];
    
    // Hide album art image to smooth rotation
    // Only if we're using imagescroller
    if (_imageScroller) {
        [UIView animateWithDuration:0.1 animations:^{
            [_imageArtwork setAlpha:0.0];
        }];
    }
}

// Things to do after rotation
- (void) didRotateFromInterfaceOrientation{
    
    // Show art again
    if (_imageScroller){
        [UIView animateWithDuration:0.1 animations:^{
            [_imageArtwork setAlpha:1.0];
        }];
    }
    
    // Update the image scroller size
    [self setupImageScroller];
    
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
    CGPoint touchLocation = [touch locationInView:[gestureRecognizer view]];
    return CGRectContainsPoint(_altTitleTapArea.frame, touchLocation);
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

#pragma mark - Buttons Actions

- (void)buttonPlayPause:(id)sender {
    // Pause if playing, play if paused
    
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePaused ||
        [_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [_musicPlayer pause];    // Pause once before playing to fix when state would get occasionally stuck at paused
        [_musicPlayer play];
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
    
    if ([_sliderBar isTracking]){
        NSTimeInterval totalTime = [[[_musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        [_musicPlayer setCurrentPlaybackTime:[_sliderBar value] * totalTime];
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
    NSAttributedString* subtitle =  [MSPStringProcessor getAttributedSubtitleFromArtist:artist
                                                                                  Album:album
                                                                           WithFontSize:_subtitleFontSize
                                                                                  Color:[_labelSongSubtitle textColor]];
    
    MPMediaItemArtwork* art = [nowPlaying valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [art imageWithSize:[_imageArtwork frame].size];
    if (!artworkImage) artworkImage = [UIImage imageNamed:@"noartplaceholder"];
    NSString* altTitle = [nowPlaying valueForProperty:MSPMediaItemPropertySortTitle];
    NSNumber* albumPid = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumPersistentID];
    NSTimeInterval totalTime = [[nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString* totalString = [MSPStringProcessor getTimeStringFromInterval:totalTime];
    
    // Display them
    [_labelSongTitle setText:title];                                                // Title
    [_labelSongSubtitle setAttributedText:subtitle];                                // Subtitle
    [self recreateMarqueeTexts];                                                    // Update bounds for Title/Subtitle
    [self changeImageWithTransitionOn:_imageArtwork withImage:artworkImage];        // Artwork
    if (_imageArtworkBack)
        [self changeImageWithTransitionOn:_imageArtworkBack withImage:nil];         // Background Artwork (Hide, show later in separate thread)
    [_labelTotalTime setText:totalString];                                          // Total time
    
    // Metadata
    _displayedSongTitle = title;                                        // Title, used to switch with alternate title
    _displayedSongAltTitle = altTitle;                                  // Alternate title
    _displayedSongPID = songPid;                                        // Persistent ID
    
    // Apply the heavy task of blurring image in background thread
    if (_imageArtworkBack)
        [self blurAndSetBackgroundImage:artworkImage PID:albumPid];
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
        [_sliderBar setValue:0.0];
    }
    else{
        NSString* elapsedString = [MSPStringProcessor getTimeStringFromInterval:elapsedTime];
        [_labelElapsedTime setText:elapsedString];
        
        float progress = elapsedTime / nowPlayingSongTotalTime;
        [_sliderBar setValue:progress];
    }
}

- (void)updateButtonsState{
    // Update button state for shuffle, repeat, and play-pause buttons
    
    MPMusicShuffleMode shuffleMode = [_musicPlayer shuffleMode];
    MPMusicRepeatMode repeatMode = [_musicPlayer repeatMode];
    
    if (shuffleMode == MPMusicShuffleModeOff){              // Shuffle off
        [_buttonShuffle setTintColor:_offColor];
    }
    else{                                                   // Shuffle on
        [_buttonShuffle setTintColor:_tintColor];
    }
    
    if (repeatMode == MPMusicRepeatModeOne){            // Repeat one
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeatone"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:_tintColor];
    }
    else if (repeatMode == MPMusicRepeatModeNone){      // Repeat off
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:_offColor];
    }
    else{                                               // Repeat all or default
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:_tintColor];
    }
    
    if ([_musicPlayer playbackState] == MPMusicPlaybackStatePaused ||
        [_musicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [_buttonPlayPause setImage:[UIImage imageNamed:FILENAME_FILLBUTTON_PLAY] forState:UIControlStateNormal];
    }
    else if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [_buttonPlayPause setImage:[UIImage imageNamed:FILENAME_FILLBUTTON_PAUSE] forState:UIControlStateNormal];
    }
    
    // Note that sometimes iPodMusicPlayer will report a wrong state
    // This is a bug with iOS
    // Please refer to http://stackoverflow.com/questions/10118726/getting-wrong-playback-state-in-mp-music-player-controller-in-ios-5
    // for more information.
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

#pragma mark - Helper Methods
- (void) changeImageWithTransitionOn:(id)view withImage:(UIImage*)image{
    // Change image in the given uiimageview with fading animation
    
    [UIView transitionWithView:view
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (_isButtonImageArtwork){
                            [(UIButton*)view setImage:image forState:UIControlStateNormal];
                        }
                        else{
                            [(UIImageView*)view setImage:image];
                        }
                    } completion:NULL];
}

- (void) blurAndSetBackgroundImage:(UIImage*)artworkImage PID:(NSNumber*)albumPid{
    // Use GCD to blur image in background thread
    // When finished, set background to the blurred image
    
    if (!_imageBlurringQueue){
        _imageBlurringQueue = dispatch_queue_create(BLURRING_QUEUE_NAME, NULL);
        _blurringQueueCount = 0;
    }
    _blurringQueueCount++;
    dispatch_async(_imageBlurringQueue, ^{
        
        // Only process image if this is the only item in queue.
        // This skips any image we don't need anymore.
        if (_blurringQueueCount == 1){
            
            MSPBlurredImagesWithCache* imageProcessor = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedBlurredImageCache];
            UIImage* blurredArt = [imageProcessor getBlurredImageOfArt:artworkImage WithPID:albumPid];
            
            // Update UI after finishing (Animated)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeImageWithTransitionOn:_imageArtworkBack withImage:blurredArt];
            });
        }
        
        _blurringQueueCount--;
    });
}

- (void) recreateMarqueeTexts{
    // Update the frame for Song title and subtitle by creating new MarqueeLabel object
    
    // Need to add an entirely new object because of bugs in the library
    MarqueeLabel* newTitle = [[MarqueeLabel alloc] initWithFrame:_labelSongTitleGuide.frame];
    MarqueeLabel* newSubtitle = [[MarqueeLabel alloc] initWithFrame:_labelSongSubtitleGuide.frame];
    
    // Use original text & styles
    [newTitle setText:[_labelSongTitle text]];
    [newTitle setFont:[_labelSongTitle font]];
    [newSubtitle setAttributedText:[_labelSongSubtitle attributedText]];
    
    // Set up the properties
    [newTitle setTextAlignment:NSTextAlignmentCenter]; // Center
    [newTitle setTextColor:_textColor];                // Color
    [newTitle setRate:MARQUEE_LABEL_RATE];             // Speed
    [newTitle setFadeLength:10.0];                     // Fade size
    [newTitle setAnimationDelay:3.0];                  // Pause
    
    [newSubtitle setTextAlignment:NSTextAlignmentCenter]; // Center
    [newSubtitle setTextColor:_textColor];                // Color
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
    [_view addSubview:newTitle];
    [_view addSubview:newSubtitle];
    
    // Show with animation
    [UIView animateWithDuration:0.1 animations:^{
        [_labelSongTitle setAlpha:1.0];
        [_labelSongSubtitle setAlpha:1.0];
    }];
}


@end
