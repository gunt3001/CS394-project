//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"
#import "MSPConstants.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPNowPlayingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelSongTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSongSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtwork;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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

- (void) refreshMediaData{
    // Refresh the media data from iPod player to the view
    
    // Grab necessary information
    MPMusicPlayerController* iPodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    MPMediaItem* nowPlaying = [iPodMusicPlayer nowPlayingItem];
    NSString* title = [nowPlaying valueForProperty:MPMediaItemPropertyTitle];
    NSString* album = [nowPlaying valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString* artist = [nowPlaying valueForProperty:MPMediaItemPropertyArtist];
    MPMediaItemArtwork* art = [nowPlaying valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [art imageWithSize:[art bounds].size];
    
    // Display them
    [[self labelSongTitle] setText:title];
    [[self labelSongSubtitle] setText:[NSString stringWithFormat:NOWPLAYING_VIEW_SUBTITLE_FORMAT, artist, album]];
    [[self imageArtwork] setImage:artworkImage];
}

@end
