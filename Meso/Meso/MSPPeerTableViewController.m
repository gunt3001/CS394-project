//
//  MSPPeerTableViewController.m
//  Meso
//
//  Created by Gun on 5/12/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPeerTableViewController.h"
#import "MSPSharingManager.h"
#import "MSPTableViewCell.h"
#import "MSPITunesHelper.h"

@interface MSPPeerTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelPeerMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelPeerMet;
@property (weak, nonatomic) IBOutlet UIImageView *imagePeerAvatar;

@end

@implementation MSPPeerTableViewController{
    AVPlayer* samplePlayer;
}

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
    
    // Set user profile
    NSString* displayName = [_peerInfo objectForKey:@"name"];
    NSString* message = [_peerInfo objectForKey:@"message"];
    NSInteger avatarID = [(NSNumber*)[_peerInfo objectForKey:@"avatar"] integerValue];
    UIImage* avatar = [MSPSharingManager avatarWithID:avatarID];
    NSNumber* numMet = [_peerInfo objectForKey:@"nummet"];
    
    [self.navigationItem setTitle:displayName];
    [_labelPeerMessage setText:message];
    [_labelPeerMet setText:[NSString stringWithFormat:@"Met %@ People", numMet]];
    [_imagePeerAvatar setImage:avatar];
     
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
    // 2 Sections, now playing and shared playlist
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:         // Now Playing
            return 1;
            break;
            
        case 1:         // Shared Playlist
        {
            NSArray* sharedPlaylist = [_peerInfo objectForKey:@"mesolist"];
            return sharedPlaylist.count;
        }
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0: //Nowplaying
            return @"Was Listening To";
            break;
        
        case 1:
            return @"Featured Playlist";
            
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idsharedsongitem" forIndexPath:indexPath];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0:     // Now Playing
        {
            NSArray* song = [_peerInfo objectForKey:@"nowplay"];
            [[cell sharedTitle] setText:song[0]];
            [[cell sharedSubtitle] setText:song[1]];
            
            // iTunes Data
            NSDictionary* iTunesStoreData = [MSPITunesHelper appleSearchApi:song[1] didGetSongName:song[0]];
            [cell setITunesStoreData:iTunesStoreData];
            
            // Artwork
            [cell.sharedImage setImage:[MSPITunesHelper artworkImage:iTunesStoreData]];
            
            
            break;
        }
        
        case 1:     // Shared Playlist
        {
            NSArray* sharedPlaylist = [_peerInfo objectForKey:@"mesolist"];
            NSArray* song = sharedPlaylist[indexPath.row];
            [[cell sharedTitle] setText:song[0]];
            [[cell sharedSubtitle] setText:song[1]];
            
            // iTunes Data
            NSDictionary* iTunesStoreData = [MSPITunesHelper appleSearchApi:song[1] didGetSongName:song[0]];
            [cell setITunesStoreData:iTunesStoreData];
            
            // Artwork
            [cell.sharedImage setImage:[MSPITunesHelper artworkImage:iTunesStoreData]];
            
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MSPTableViewCell* selectedCell = (MSPTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    samplePlayer = [MSPITunesHelper playPreviewSound:selectedCell.iTunesStoreData];
}

@end
