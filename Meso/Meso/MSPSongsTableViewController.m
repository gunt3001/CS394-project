//
//  MSPSongsTableViewController.m
//  Meso
//
//  Created by Gun on 19/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPSongsTableViewController.h"
#import "MSPTableViewCell.h"
#import "MSPConstants.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPSongsTableViewController ()

@end

@implementation MSPSongsTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections
    
    // 1 for Shuffle + Whatever number of sections is returned by the MediaQuery object
    MPMediaQuery* allSongsQuery = [self getAllSongsWithoutICloudQuery];
    return 1 + [[allSongsQuery itemSections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // 1 row for the shuffle section
    if (section == 0) return 1;
    
    MPMediaQuery* allSongsQuery = [self getAllSongsWithoutICloudQuery];
    MPMediaQuerySection* thisSection = [[allSongsQuery collectionSections] objectAtIndex:(section - 1)];
    return [thisSection range].length;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return the height for rows in table
    
    // Shuffle button have reduced height
    if ([indexPath section] == 0){
        return TABLE_VIEW_SHUFFLE_ROW_HEIGHT;
    }
    
    // Songs have regular height
    else return [tableView rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the cell for the table
    
    MSPTableViewCell* cell;
    MPMediaQuery* allSongsQuery = [self getAllSongsWithoutICloudQuery];
    
    // First section is always the shuffle item
    if ([indexPath section] == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"idshuffleitem" forIndexPath:indexPath];
        
        NSInteger songsCount = [[allSongsQuery items] count];
        NSString* songsCountText = [NSString stringWithFormat:@"%ld Songs", (long)songsCount];
        [[cell detailTextLabel] setText:songsCountText];
    }
    // Otherwise it's a song
    else{
        // Get song object from library
        NSInteger section = [indexPath section] - 1; // -1 to offset for shuffle
        NSInteger row = [indexPath row];
        MPMediaQuerySection* thisSection = [[allSongsQuery itemSections] objectAtIndex:section];
        NSInteger sectionOffset = [thisSection range].location;
        MPMediaItem* song = [[allSongsQuery items] objectAtIndex:(sectionOffset + row)];
        
        // Grab song data
        // Title
        NSString* songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
        // Artist
        NSString* songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
        // Album
        NSString* songAlbum = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
        // Artwork
        MPMediaItemArtwork* songArt = [song valueForProperty:MPMediaItemPropertyArtwork];
        UIImage* songArtImage = [songArt imageWithSize:(CGSizeMake(TABLE_VIEW_ALBUM_ART_WIDTH, TABLE_VIEW_ALBUM_ART_HEIGHT))];
        // Unique Persistent ID for the song
        NSNumber* songPID = [song valueForProperty:MPMediaItemPropertyPersistentID];
        
        // Set cell data
        // If cell has artwork
        if (songArtImage != nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
            [[cell imageView] setImage:songArtImage];
        }
        // Otherwise use the cell without artwork
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitemnoart" forIndexPath:indexPath];
        }
        // Title
        [[cell textLabel] setText:songTitle];
        // Subtitle
        if (songArtist == nil) songArtist = @"Unknown Artist";
        if (songAlbum == nil) songAlbum = @"Unknown Album";
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@", songArtist, songAlbum]];
        // PID
        [cell setPID:songPID];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    // Return the section titles
    
    // First section (shuffle) does not have title
    if (section == 0) return nil;
    
    MPMediaQuery* allSongsQuery = [self getAllSongsWithoutICloudQuery];
    return [[[allSongsQuery collectionSections] objectAtIndex:(section - 1)] title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    // Return the section titles for indexing
    
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    
    // The first section (shuffle)
    [indexes addObject:@"↻"];

    // Add the rest from library
    MPMediaQuery* allSongsQuery = [self getAllSongsWithoutICloudQuery];
    for (MPMediaQuerySection* eachSection in [allSongsQuery itemSections]){
        [indexes addObject:[eachSection title]];
    }
    
    return indexes;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
    // Start playing selected music
    if ([sender isKindOfClass:[MSPTableViewCell class]]){
        MSPTableViewCell* selectedCell = (MSPTableViewCell*) sender;
        
        // If it's a song
        if ([selectedCell PID] != nil){
            // Query the song object from the stored PID
            MPMediaQuery* songQuery = [self getAllSongsWithoutICloudQuery];
            [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[selectedCell PID] forProperty:MPMediaItemPropertyPersistentID]];
            MPMediaItem* song = [[songQuery items] objectAtIndex:0];
            
            // Set the playing Queue to be all songs, not including iCloud items
            MPMediaQuery* allSongs = [self getAllSongsWithoutICloudQuery];
            
            // Ask the iPod to play it
            MPMusicPlayerController* iPodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
            [iPodMusicPlayer setQueueWithQuery:allSongs];
            [iPodMusicPlayer setNowPlayingItem:song];
            
            // Cycle shuffle mode so that the new song is first in the playing queue
            if ([iPodMusicPlayer shuffleMode] != MPMusicShuffleModeOff){
                [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
                [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
            }
            
            [iPodMusicPlayer play];
        }
        // If it's the shuffle button
        else{
            // Set the playing Queue to be all songs, not including iCloud items
            MPMediaQuery* allSongs = [self getAllSongsWithoutICloudQuery];
            
            // Ask the iPod to play it
            MPMusicPlayerController* iPodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
            [iPodMusicPlayer setQueueWithQuery:allSongs];
            
            [iPodMusicPlayer play];
        }
    }
}

#pragma mark - Helper Methods

- (MPMediaQuery*) getAllSongsWithoutICloudQuery{
    // Return a MPMediaQuery of all songs in the iPod Library without iCloud music
    
    MPMediaQuery* allSongs = [MPMediaQuery songsQuery];
    [allSongs addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    
    return allSongs;
}


@end
