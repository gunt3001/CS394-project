//
//  MSPPlaylistsTableViewController.m
//  Meso
//
//  Created by Gun on 21/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPlaylistsTableViewController.h"
#import "MSPPlaylistsViewController.h"
#import "MSPAppDelegate.h"
#import "MSPConstants.h"
#import "MSPTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPPlaylistsTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MSPPlaylistsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Refer to the tree structure in the parent view controller, if not set by previous viewcontroller
    if (!_playlistTree){
        _playlistTree = [((MSPPlaylistsViewController*)[self parentViewController]) playlistTree];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // There is only one section for playlists
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // If this table is showing songs
    if (_playlistPID){
        
        // Query the songs from this playlist from the music library
        MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
        [playlistsQuery addFilterPredicate:[MPMediaPropertyPredicate
                                            predicateWithValue:_playlistPID
                                            forProperty:MPMediaPlaylistPropertyPersistentID]];
        MPMediaPlaylist* playlist = [[playlistsQuery collections] objectAtIndex:0];
        
        // Return number of songs in this playlist
        return [[playlist items] count];
    }
    // If this table is showing playlists{
    else if (_playlistTree){
        // Return number of children of this tree node
        return [_playlistTree childrenCount];
    }
    
    return 0;       // Fallback with empty table
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the cell for the table
    
    // If this table is showing songs
    if (_playlistPID){
        
        MSPTableViewCell* cell;
        
        // First row is the shuffle button
        if ([indexPath row] == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"idshuffleitem" forIndexPath:indexPath];
            
            NSInteger songsCount = [tableView numberOfRowsInSection:0] - 1;
            NSString* songsCountText = [NSString stringWithFormat:TABLE_VIEW_SONG_COUNT_FORMAT, (long)songsCount];
            [[cell detailTextLabel] setText:songsCountText];
        }
        
        // Songs
        else{
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
            
            // Query the songs from this playlist from the music library
            MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
            [playlistsQuery addFilterPredicate:[MPMediaPropertyPredicate
                                                predicateWithValue:_playlistPID
                                                forProperty:MPMediaPlaylistPropertyPersistentID]];
            MPMediaPlaylist* playlist = [[playlistsQuery collections] objectAtIndex:0];
            MPMediaItem* song = [[playlist items] objectAtIndex:[indexPath row] - 1];           // Offset by 1 for shuffle button
            
            // Get song info
            // Title
            NSString* songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
            // Artist
            NSString* songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
            // Album
            NSString* songAlbum = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            // Artwork
            MPMediaItemArtwork* songArt = [song valueForProperty:MPMediaItemPropertyArtwork];
            
            // Set cell data
            [[cell textLabel] setText:songTitle];
            if (songArtist == nil) songArtist = STRING_UNKNOWN_ARTIST;
            if (songAlbum == nil) songAlbum = STRING_UNKNOWN_ALBUM;
            [[cell detailTextLabel] setText:[NSString stringWithFormat:TABLE_VIEW_SUBTITLE_FORMAT, songArtist, songAlbum]];
            // Artwork
            [cell addThumbnailWithMediaItemArtwork:songArt];
            [cell setIndentationWidth:(TABLE_VIEW_ALBUM_ART_WIDTH)];
        }
        
        return cell;
    }
    
    // If this table is showing playlists{
    else if (_playlistTree){
        UITableViewCell* cell;
        
        MSPPlaylistNode* playlist = [[_playlistTree children] objectAtIndex:[indexPath row]];
        
        if ([playlist isFolder]) cell = [tableView dequeueReusableCellWithIdentifier:@"idplaylistfolderitem" forIndexPath:indexPath];
        else cell = [tableView dequeueReusableCellWithIdentifier:@"idplaylistitem" forIndexPath:indexPath];
        
        // Set cell data
        [[cell textLabel] setText:[playlist name]];
        
        return cell;
    }
    
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return the height for rows in table
    
    // If we're showing songs inside a playlist
    if (_playlistPID){
        
        // Shuffle button have reduced height
        if ([indexPath row] == 0){
            return TABLE_VIEW_SHUFFLE_ROW_HEIGHT;
        }
        
        // Songs have height as set in constants
        return TABLE_VIEW_SONG_ROW_HEIGHT;
    }
    // If we're showing playlists, use default height
    else return [tableView rowHeight];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // If user tapped an item in the table
    if ([sender isKindOfClass:[UITableViewCell class]]){
        UITableViewCell* senderCell = (UITableViewCell*) sender;
        
        // If it's a playlist folder
        if ([[senderCell reuseIdentifier] isEqualToString:@"idplaylistfolderitem"]){
            
            // Then destination is this view itself
            MSPPlaylistsTableViewController* destination = (MSPPlaylistsTableViewController*)[segue destinationViewController];
            
            // Items in table is the subtree of selected item
            NSInteger indexOfSelectedCell = [[[self tableView] indexPathForCell:senderCell] row];
            MSPPlaylistNode* subTree = [[_playlistTree children] objectAtIndex:indexOfSelectedCell];
            [destination setPlaylistTree:subTree];

            // Set new title
            [destination setTitle:[subTree name]];
        }
        // If it's a playlist
        else if ([[senderCell reuseIdentifier] isEqualToString:@"idplaylistitem"]){
            // Then destination is this view itself
            MSPPlaylistsTableViewController* destination = (MSPPlaylistsTableViewController*)[segue destinationViewController];
            
            // Items in new table are the songs. We give the new view a MPMediaPlaylist object
            NSInteger indexOfSelectedCell = [[[self tableView] indexPathForCell:senderCell] row];
            MSPPlaylistNode* subTree = [[_playlistTree children] objectAtIndex:indexOfSelectedCell];

            [destination setPlaylistPID:[subTree pid]];
            
            // Set new title
            [destination setTitle:[subTree name]];
        }
        // If it's a song
        else if ([[senderCell reuseIdentifier] isEqualToString:@"idsongitem"]){
            
            MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
            
            // Query the song
            MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
            [playlistsQuery addFilterPredicate:[MPMediaPropertyPredicate
                                                predicateWithValue:_playlistPID
                                                forProperty:MPMediaPlaylistPropertyPersistentID]];
            MPMediaPlaylist* playlist = [[playlistsQuery collections] objectAtIndex:0];
            NSIndexPath* indexPath = [[self tableView] indexPathForCell:senderCell];
            MPMediaItem* song = [[playlist items] objectAtIndex:[indexPath row] - 1];       // Offset by 1 for shuffle button
            
            // Temporarily turn off shuffle
            MPMusicShuffleMode oldShufMode = [iPodMusicPlayer shuffleMode];
            [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
            
            // Set playing queue and now playing item
            [iPodMusicPlayer setQueueWithQuery:playlistsQuery];
            [iPodMusicPlayer setNowPlayingItem:song];
            
            // Turn shuffle back on, if it was on
            if (oldShufMode != MPMusicShuffleModeOff){
                [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeDefault];
            }
            
            [iPodMusicPlayer play];
            
        }
        // If it's a shuffle button
        else if ([[senderCell reuseIdentifier] isEqualToString:@"idshuffleitem"]){
            
            MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
            
            // Query Playlist
            MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
            [playlistsQuery addFilterPredicate:[MPMediaPropertyPredicate
                                                predicateWithValue:_playlistPID
                                                forProperty:MPMediaPlaylistPropertyPersistentID]];
            // Set playing queue
            [iPodMusicPlayer setQueueWithQuery:playlistsQuery];
            
            // Turn on shuffle
            [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
            
            [iPodMusicPlayer play];
        }
    }
}


@end
