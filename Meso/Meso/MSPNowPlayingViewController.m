//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"
#import "MSPAppDelegate.h"
#import "MSPConstants.h"
#import "MSPStringProcessor.h"
#import "MSPBlurredImagesWithCache.h"
#import "MarqueeLabel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPNowPlayingViewController ()
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtworkBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroller;
@property (weak, nonatomic) IBOutlet UILabel *labelElapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (weak, nonatomic) IBOutlet UIButton *buttonRepeat;

@end

@implementation MSPNowPlayingViewController {
    dispatch_queue_t imageBlurringQueue;
    int blurringQueueCount;
    BOOL isShowingAltTitle;
    NSTimer* elapsedTimer;
    NSTimer* fastSeekTimer;
    
    // Also store other now playing metadata
    NSString* nowPlayingSongTitle;
    NSString* nowPlayingSongAlternateTitle;
    NSTimeInterval nowPlayingSongTotalTime;
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any initialization not possible in Storyboard
    [self setupMediaUpdate];                // Subscribe to media status changes
    [self setupSongTitleGesture];           // Enable tapping on song title to show alternate title
    [self setupImageArtworkDropShadow];     // Add Drop Shadow to Art Image
    [self setupImageScroller];              // Use imagescroller to allow song skipping by swiping
    [self setupTimer];                      // Set up timer to keep track of elapsed time
    [self setupMarquee];                    // Set up scrolling text
    
    // Do the initial update of now playing item
    [self updateMediaData];
}

- (void) viewDidAppear:(BOOL)animated{
    // Doing setup when view has already appeared
    
    // Call restart to begin marquee animation, only after view has loaded
    // Otherwise the animation might get cancelled
    [MarqueeLabel restartLabelsOfController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

- (void) setupMarquee{
    // Set up scrolling text
    
    // Set color
    [_labelSongTitle setTextColor:[UIColor whiteColor]];
    [_labelSongSubtitle setTextColor:[UIColor whiteColor]];
    
    // Set speed
    [_labelSongTitle setRate:MARQUEE_LABEL_RATE];
    [_labelSongSubtitle setRate:MARQUEE_LABEL_RATE];
    
    // Set fade length
    [_labelSongTitle setFadeLength:10.0];
    [_labelSongSubtitle setFadeLength:10.0];
    
    // Set a small pause
    [_labelSongTitle setAnimationDelay:3.0];
    [_labelSongSubtitle setAnimationDelay:3.0];
}

- (void)setupTimer{
    // Setup timer to keep track of elapsed time
    
    // Update the elapsed tiem every 1 second
    elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateElapsedTime)
                                           userInfo:nil repeats:YES];
}

- (void)setupMediaUpdate{
    // Subscribe to media status changes
    MPMusicPlayerController* sharedPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:sharedPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(handlePlaybackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:sharedPlayer];
}

- (void)setupSongTitleGesture{
    // Enable tapping on song title to show alternate title
    isShowingAltTitle = NO;
    UITapGestureRecognizer* tapToViewAltTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAltTitle:)];
    [tapToViewAltTitle setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapToViewAltTitle];
}

- (void) setupImageArtworkDropShadow{
    // Add Drop Shadow to Art Image
    [[_imageArtwork layer] setShadowColor:[UIColor blackColor].CGColor];
    [[_imageArtwork layer] setShadowOffset:CGSizeMake(0.0, 0.0)];
    [[_imageArtwork layer] setShadowOpacity:1.0];
    [[_imageArtwork layer] setShadowRadius:2.0];
    [_imageArtwork setClipsToBounds:NO];
}

- (void) setupImageScroller{
    // Use imagescroller to allow song skipping by swiping
    // Content is 3x screen size to allow swiping left and right
    [_imageScroller setContentSize:CGSizeMake([_imageScroller frame].size.width * 3.0,
                                              [_imageScroller frame].size.height)];
    // Move the art image to the center
    [_imageArtwork setFrame:CGRectMake([_imageArtwork frame].origin.x + [_imageScroller frame].size.width,
                                       [_imageArtwork frame].origin.y,
                                       [_imageArtwork frame].size.width,
                                       [_imageArtwork frame].size.height)];
    
    // Set new origins to follow
    [_imageScroller setContentOffset:CGPointMake([_imageScroller frame].size.width, 0.0)];
}

#pragma mark - Gestures

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Action when scroller page has changed (user has swiped the album art image)
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    // If we swiped right, skip to previous song
    if (page == 0){
        MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
        [iPodMusicPlayer skipToPreviousItem];
    }
    // Swiping left, skip to next song
    else if (page == 2){
        MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
        [iPodMusicPlayer skipToNextItem];
    }
    
    // If we changed track, smooth the transition to next art
    if (page == 0 || page == 2){
        // Hide art
        [_imageArtwork setImage:nil];
        
        // Reset back to page 1
        [_imageScroller setContentOffset:CGPointMake([_imageScroller frame].size.width, 0.0)];
    }
}

- (void)showAltTitle:(UITapGestureRecognizer*) sender{
    // Show alternate song title
    
    // Prepare to animate text change
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.2;
    [_labelSongTitle.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    if (CGRectContainsPoint(_labelSongTitle.frame, [sender locationInView:self.view])){
        if (isShowingAltTitle){
            [_labelSongTitle setText:nowPlayingSongTitle];
            isShowingAltTitle = NO;
        }
        else {
            [_labelSongTitle setText:nowPlayingSongAlternateTitle];
            isShowingAltTitle = YES;
        }
    }
    
}

#pragma mark - Buttons

- (IBAction)buttonBack:(id)sender {
    // Back button action - dismiss current view
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)buttonPlayPause:(id)sender {
    // Pause if playing, play if paused
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePaused ||
        [iPodMusicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [iPodMusicPlayer pause];    // Pause once before playing to fix when state would get occasionally stuck at paused
        [iPodMusicPlayer play];
    }
    else if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [iPodMusicPlayer pause];
    }
}

- (IBAction)buttonForward:(id)sender {
    // Skip to next song, or stop fast forwarding
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Stop timer when we touched down
    if (fastSeekTimer != nil){
        [fastSeekTimer invalidate];
        fastSeekTimer = nil;
    }
    
    // If we're fast forwarding, stop it and don't skip to next song
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [iPodMusicPlayer currentPlaybackRate] != 1.0){
        [iPodMusicPlayer setCurrentPlaybackRate:1.0];
    }
    // Otherwise we're skipping to next song
    else{
        [iPodMusicPlayer skipToNextItem];
    }
    
}
- (IBAction)buttonBackward:(id)sender {
    // Skip to beginning, or to previous song if at less than 0:05
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Stop timer when we touched down
    if (fastSeekTimer != nil){
        [fastSeekTimer invalidate];
        fastSeekTimer = nil;
    }
    
    // If we're fast forwarding, stop it and don't skip
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [iPodMusicPlayer currentPlaybackRate] != 1.0){
        [iPodMusicPlayer setCurrentPlaybackRate:1.0];
    }
    // Otherwise we're doing skipping logic
    else{
        if ([iPodMusicPlayer currentPlaybackTime] <= 3.0){
            [iPodMusicPlayer skipToPreviousItem];
        }
        else{
            [iPodMusicPlayer skipToBeginning];
        }
    }
    
    
}
- (IBAction)buttonBackwardTouchUpOutside:(id)sender {
    // When buttton is touched up outside
    // Invalidate timer when touched down
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];

    // Stop timer when we touched down
    if (fastSeekTimer){
        [fastSeekTimer invalidate];
        fastSeekTimer = nil;
    }
    // Stop any fast forwarding
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [iPodMusicPlayer currentPlaybackRate] != 1.0){
        [iPodMusicPlayer setCurrentPlaybackRate:1.0];
    }
}
- (IBAction)buttonForwardTouchUpOutside:(id)sender {
    // When buttton is touched up outside
    // Invalidate timer when touched down
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];

    // Stop timer when we touched down
    if (fastSeekTimer){
        [fastSeekTimer invalidate];
        fastSeekTimer = nil;
    }
    // Stop any fast forwarding
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying
        && [iPodMusicPlayer currentPlaybackRate] != 1.0){
        [iPodMusicPlayer setCurrentPlaybackRate:1.0];
    }
}

- (IBAction)buttonUpNext:(id)sender {
    // Show the up-next menu
    
    // Unimplemented
    
}

- (IBAction)buttonShuffle:(id)sender {
    // Toggle between shuffle states
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    MPMusicShuffleMode shuffleMode = [iPodMusicPlayer shuffleMode];
    
    if (shuffleMode == MPMusicShuffleModeOff){              // Shuffle off
        [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    }
    else{                                                   // Shuffle on
        [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
    }
    
    [self updateShuffleRepeatButtonState];
}

- (IBAction)buttonRepeat:(id)sender {
    // Toggle between repeat states
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    MPMusicRepeatMode repeatMode = [iPodMusicPlayer repeatMode];
    
    if (repeatMode == MPMusicRepeatModeOne){            // Repeat one
        [iPodMusicPlayer setRepeatMode:MPMusicRepeatModeAll];
    }
    else if (repeatMode == MPMusicRepeatModeNone){      // Repeat off
        [iPodMusicPlayer setRepeatMode:MPMusicRepeatModeOne];
    }
    else{                                               // Repeat all or default
        [iPodMusicPlayer setRepeatMode:MPMusicRepeatModeNone];
    }
    
    [self updateShuffleRepeatButtonState];
}
- (IBAction)buttonForwardTouchDown:(id)sender {
    // When forward button is touched
    // Start a new timer
    // If button is not lifted within a certain time, start fast forwarding
    
    fastSeekTimer = [NSTimer scheduledTimerWithTimeInterval:FAST_SEEKING_DELAY
                                                    target:self
                                                  selector:@selector(fastForward)
                                                  userInfo:nil repeats:NO];
}
- (IBAction)buttonBackwardTouchDown:(id)sender {
    // When backward button is touched
    // Start a new timer
    // If button is not lifted within a certain time, start fast seeking backwards
    
    fastSeekTimer = [NSTimer scheduledTimerWithTimeInterval:FAST_SEEKING_DELAY
                                                     target:self
                                                   selector:@selector(fastBackward)
                                                   userInfo:nil repeats:NO];
}

- (void) fastForward{
    // Start fast forwarding
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    [iPodMusicPlayer setCurrentPlaybackRate:FAST_SEEKING_RATE];
}

- (void) fastBackward{
    // Start fast seeking backwards
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    [iPodMusicPlayer setCurrentPlaybackRate:FAST_SEEKING_RATE * -1];
}
#pragma mark - View & Orientations

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Responding to Media Changes

- (void) updateMediaData{
    // Refresh the media data from iPod player to the view
    
    // Reset flags
    isShowingAltTitle = NO;
    
    // Update UI Elements that are not affected by now playing status
    [self updatePlayPauseButtonState];          // Play-pause button
    [self updateShuffleRepeatButtonState];      // Shuffle and repeat buttons
    
    // Check if we're playing anything at all
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [[self labelSongTitle] setText:STRING_NOTHING_PLAYING];
        [[self labelSongSubtitle] setText:@""];
        [self changeImageWithTransitionOn:_imageArtwork withImage:nil];
        [self changeImageWithTransitionOn:_imageArtworkBack withImage:nil];
        [[self labelElapsedTime] setText:@"-"];
        [[self labelTotalTime] setText:@"-"];
        nowPlayingSongTitle = STRING_NOTHING_PLAYING;
        nowPlayingSongAlternateTitle = STRING_NOTHING_PLAYING;
        return;
    }
    
    // Grab necessary information
    MPMediaItem* nowPlaying = [iPodMusicPlayer nowPlayingItem];
    NSString* title = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
    NSString* album = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString* artist = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
    NSAttributedString* subtitle =  [MSPStringProcessor getAttributedSubtitleFromArtist:artist
                                                                                  Album:album
                                                                           WithFontSize:[[[self labelSongSubtitle] font] pointSize]
                                                                                  Color:[[self labelSongSubtitle] textColor]];
    MPMediaItemArtwork* art = [nowPlaying valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [art imageWithSize:[_imageArtwork frame].size];
    NSString* altTitle = [nowPlaying valueForProperty:MSPMediaItemPropertySortTitle];
    NSNumber* albumPid = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumPersistentID];
    NSTimeInterval totalTime = [[nowPlaying valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString* totalString = [MSPStringProcessor getTimeStringFromInterval:totalTime];

    // Display them
    [[self labelSongTitle] setText:title];                                          // Title
    [[self labelSongSubtitle] setAttributedText:subtitle];                          // Subtitle
    [self changeImageWithTransitionOn:_imageArtwork withImage:artworkImage];        // Artwork
    [self changeImageWithTransitionOn:_imageArtworkBack withImage:nil];             // Background Artwork (nil for now)
    [self updateElapsedTime];                                                       // Elapsed time
    [[self labelTotalTime] setText:totalString];                                    // Total time
    
    
    // Metadata
    nowPlayingSongTitle = title;                                        // Title, used to switch with alternate title
    nowPlayingSongAlternateTitle = altTitle;                            // Alternate title
    nowPlayingSongTotalTime = totalTime;                                // Total time, used to update progress bar
    
    // Apply the heavy task of blurring image in background thread
    [self blurAndSetBackgroundImage:artworkImage PID:albumPid];
}

- (void)updateElapsedTime{
    // Update the elapsed time label and the progress bar
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    NSTimeInterval elapsedTime = [iPodMusicPlayer currentPlaybackTime];
    NSString* elapsedString = [MSPStringProcessor getTimeStringFromInterval:elapsedTime];
    [[self labelElapsedTime] setText:elapsedString];
    
    float progress = elapsedTime / nowPlayingSongTotalTime;
    [[self progressBar] setProgress:progress];
}

- (void)updateShuffleRepeatButtonState{
    // Update button state for shuffle and repeat buttons
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];

    MPMusicShuffleMode shuffleMode = [iPodMusicPlayer shuffleMode];
    MPMusicRepeatMode repeatMode = [iPodMusicPlayer repeatMode];
    
    if (shuffleMode == MPMusicShuffleModeOff){              // Shuffle off
        [_buttonShuffle setTintColor:[UIColor blackColor]];
    }
    else{                                                   // Shuffle on
        [_buttonShuffle setTintColor:[UIColor whiteColor]];
    }
    
    if (repeatMode == MPMusicRepeatModeOne){            // Repeat one
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeatone"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:[UIColor whiteColor]];
    }
    else if (repeatMode == MPMusicRepeatModeNone){      // Repeat off
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:[UIColor blackColor]];
    }
    else{                                               // Repeat all or default
        [_buttonRepeat setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [_buttonRepeat setTintColor:[UIColor whiteColor]];
    }
}

- (void)updatePlayPauseButtonState{
    // Refresh play button to reflect current playing status
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];

    if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePaused ||
        [iPodMusicPlayer playbackState] == MPMusicPlaybackStateStopped){
        [_buttonPlayPause setImage:[UIImage imageNamed:FILENAME_FILLBUTTON_PLAY] forState:UIControlStateNormal];
    }
    else if ([iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying){
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
    
    [self updatePlayPauseButtonState];      // Play/Pause Button state
    [self updateElapsedTime];               // Playback Time
}

#pragma mark - Helper Methods
- (void) changeImageWithTransitionOn:(UIImageView*)view withImage:(UIImage*)image{
    // Change image in the given uiimageview with fading animation
    
    [UIView transitionWithView:view
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [view setImage:image];
                    } completion:NULL];
}

- (void) blurAndSetBackgroundImage:(UIImage*)artworkImage PID:(NSNumber*)albumPid{
    // Use GCD to blur image in background thread
    // When finished, set background to the blurred image
    
    if (!imageBlurringQueue){
        imageBlurringQueue = dispatch_queue_create(BLURRING_QUEUE_NAME, NULL);
        blurringQueueCount = 0;
    }
    blurringQueueCount++;
    dispatch_async(imageBlurringQueue, ^{
        
        // Only process image if this is the only item in queue.
        // This skips any image we don't need anymore.
        if (blurringQueueCount == 1){
            
            MSPBlurredImagesWithCache* imageProcessor = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedBlurredImageCache];
            UIImage* blurredArt = [imageProcessor getBlurredImageOfArt:artworkImage WithPID:albumPid];
            
            // Update UI after finishing (Animated)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeImageWithTransitionOn:_imageArtworkBack withImage:blurredArt];
            });
        }
        
        blurringQueueCount--;
    });
}
@end
