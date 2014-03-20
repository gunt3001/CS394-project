//
//  MSPSongsTableViewController.m
//  Meso
//
//  Created by Gun on 19/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPSongsTableViewController.h"
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
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    return 1 + [[allSongsQuery itemSections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // 1 row for the shuffle section
    if (section == 0) return 1;
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    MPMediaQuerySection* thisSection = [[allSongsQuery collectionSections] objectAtIndex:(section - 1)];
    return [thisSection range].length;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the cell for the table
    UITableViewCell *cell;
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    
    // First section is always the shuffle item
    if ([indexPath section] == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"idshuffleitem" forIndexPath:indexPath];
        
        NSInteger songsCount = [[allSongsQuery items] count];
        NSString* songsCountText = [NSString stringWithFormat:@"%d Songs", songsCount];
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
        UIImage* songArtImage = [songArt imageWithSize:(CGSizeMake(50.0, 50.0))];
        
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
                
    }
    
    return cell;
}

#pragma Sections and Indexing

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    // Return the section titles
    
    // First section (shuffle) does not have title
    if (section == 0) return nil;
    
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    return [[[allSongsQuery collectionSections] objectAtIndex:(section - 1)] title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    // Return the section titles for indexing
    
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    
    // The first section (shuffle) does not need indexing
    [indexes addObject:@"↻"];

    // Add the rest from library
    MPMediaQuery* allSongsQuery = [MPMediaQuery songsQuery];
    for (MPMediaQuerySection* eachSection in [allSongsQuery itemSections]){
        [indexes addObject:[eachSection title]];
    }
    
    return indexes;
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

@end
