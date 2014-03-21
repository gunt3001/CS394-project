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
#import "UIImage+ImageEffects.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPNowPlayingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtworkBack;

@end

@implementation MSPNowPlayingViewController

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
    
    // Do the initial update of now playing item
    [self refreshMediaData];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)buttonBack:(id)sender {
    // Back button action - dismiss current view
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View Orientations

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

- (void) refreshMediaData{
    // Refresh the media data from iPod player to the view
    
    // Grab necessary information
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    MPMediaItem* nowPlaying = [iPodMusicPlayer nowPlayingItem];
    NSString* title = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
    NSString* album = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString* artist = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
    MPMediaItemArtwork* art = [nowPlaying valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [art imageWithSize:[_imageArtwork frame].size];
    
    // Display them
    [[self labelSongTitle] setText:title];
    [[self labelSongSubtitle] setText:[NSString stringWithFormat:NOWPLAYING_VIEW_SUBTITLE_FORMAT, artist, album]];
    
    // Artwork (Animated)
    [self changeImageWithTransitionOn:_imageArtwork withImage:artworkImage];
    
    // Background Artwork (Animated)
    // For now, set it to nil because blurring takes a little while
    [self changeImageWithTransitionOn:_imageArtworkBack withImage:nil];
    
    // Apply the heavy task of blurring image in background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* blurredArt = [artworkImage applyDarkEffect];
        
        // Update UI after finishing (Animated)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeImageWithTransitionOn:_imageArtworkBack withImage:blurredArt];
        });
    });
    
}

- (void)handleNowPlayingItemChanged:(id)notification {
    [self refreshMediaData];
}

- (void)handlePlaybackStateChanged:(id)notification {
#warning unimplemented
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

@end
