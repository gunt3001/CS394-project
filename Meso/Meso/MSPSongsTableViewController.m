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
#import "MSPAppDelegate.h"
#import "MSPStringProcessor.h"
#import "MSPMediaPlayerHelper.h"
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
    MPMediaQuery* allSongsQuery = [MSPMediaPlayerHelper allSongsWithoutICloud];
    return 1 + [[allSongsQuery itemSections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // 1 row for the shuffle section
    if (section == 0) return 1;
    
    MPMediaQuery* allSongsQuery = [MSPMediaPlayerHelper allSongsWithoutICloud];
    MPMediaQuerySection* thisSection = [[allSongsQuery collectionSections] objectAtIndex:(section - 1)];
    return [thisSection range].length;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return the height for rows in table
    
    // Shuffle button have reduced height
    if ([indexPath section] == 0){
        return 45;
    }
    
    // Songs have regular height
    else return TABLE_VIEW_SONG_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the cell for the table
    
    MSPTableViewCell* cell;
    MPMediaQuery* allSongsQuery = [MSPMediaPlayerHelper allSongsWithoutICloud];
    
    // First section is always the shuffle item
    if ([indexPath section] == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"idshuffleitem" forIndexPath:indexPath];
        
        NSInteger songsCount = [[allSongsQuery items] count];
        NSString* songsCountText = [NSString stringWithFormat:TABLE_VIEW_SONG_COUNT_FORMAT, (long)songsCount];
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
        
        // Set cell data
        cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
        [cell setSongInfo:song WithString:nil];
    }
    
    return cell;
}

#pragma mark Indexing

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    // Return the section titles
    
    // First section (shuffle) does not have title
    if (section == 0) return nil;
    
    MPMediaQuery* allSongsQuery = [MSPMediaPlayerHelper allSongsWithoutICloud];
    return [[[allSongsQuery collectionSections] objectAtIndex:(section - 1)] title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    // Return the section titles for indexing
    
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    
    // The first section (shuffle) don't need indexing

    // Add the rest from library
    MPMediaQuery* allSongsQuery = [MSPMediaPlayerHelper allSongsWithoutICloud];
    for (MPMediaQuerySection* eachSection in [allSongsQuery itemSections]){
        [indexes addObject:[eachSection title]];
    }
    
    return indexes;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    // Return the appropriate section index according to the index title
    
    // Since the shuffle section does not have an index, the rest of the sections are offset by 1
    return index + 1;
    
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
        if ([selectedCell PID]){
            // Query the song object from the stored PID
            MPMediaItem* song = [MSPMediaPlayerHelper songFromPID:[selectedCell PID]];
                        
            // Set the playing Queue to be all songs, not including iCloud items
            MPMediaQuery* allSongs = [MSPMediaPlayerHelper allSongsWithoutICloud];
            
            // Play
            [MSPMediaPlayerHelper playSong:song QueueQuery:allSongs];
        }
        // If it's the shuffle button
        else{
            // Set the playing Queue to be all songs, not including iCloud items
            MPMediaQuery* allSongs = [MSPMediaPlayerHelper allSongsWithoutICloud];
            
            // Ask the iPod to play it
            [MSPMediaPlayerHelper playQuery:allSongs ForceShuffle:YES];
        }
    }
}

@end
