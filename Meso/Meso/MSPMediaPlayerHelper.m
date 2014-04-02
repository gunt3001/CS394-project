//
//  MSPMediaQueryHelper.m
//  Meso
//
//  Created by Gun on 3/28/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPMediaPlayerHelper.h"
#import "MSPAppDelegate.h"
#import "MPMusicPlayerController+CurrentQueue.h"

@implementation MSPMediaPlayerHelper

#pragma mark - Getting Media Entities

/// Return MPMediaPlaylist* of playlist with given pid
+ (MPMediaPlaylist *)playlistFromPID:(NSNumber *)pid{
    MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
    [playlistsQuery addFilterPredicate:[MPMediaPropertyPredicate
                                        predicateWithValue:pid
                                        forProperty:MPMediaPlaylistPropertyPersistentID]];
    MPMediaPlaylist* playlist = [[playlistsQuery collections] objectAtIndex:0];
    return playlist;
}

/// Return MPMediaItem* of song with given pid
+ (MPMediaItem *)songFromPID:(NSNumber *)pid{
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    [songQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:pid forProperty:MPMediaItemPropertyPersistentID]];
    MPMediaItem* song = [[songQuery items] objectAtIndex:0];
    return song;
}

/// Return a query of all songs on the local device
+ (MPMediaQuery*) allSongsWithoutICloud{
    MPMediaQuery* allSongs = [MPMediaQuery songsQuery];
    [allSongs addFilterPredicate:[MPMediaPropertyPredicate
                                  predicateWithValue:[NSNumber numberWithBool:NO]
                                  forProperty:MPMediaItemPropertyIsCloudItem]];
    
    return allSongs;
}

#pragma mark - Currently Playing Queue

/// Return an MPMediaItem in playing queue with specified index
+ (MPMediaItem *)nowPlayingItemAtIndex:(NSInteger)index{
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)index];
}

/// Return an MPMediaItem in playing queue with offset from now playing item
/// Exmaple- An offset of 0 means the next song in queue
+ (MPMediaItem *)nowPlayingItemFromCurrentOffset:(NSInteger)offset{
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    NSInteger nextItemIndex = [iPodMusicPlayer indexOfNowPlayingItem] + 1 + offset;
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)nextItemIndex];
}

/// Return the number of items left in the currently playing queue
+ (NSInteger)itemsLeftInPlayingQueue{
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    return [iPodMusicPlayer numberOfItems] - ([iPodMusicPlayer indexOfNowPlayingItem] + 1);
}

/// Remove the given item from the currently playing them
+ (void) removeNowPlayingItemAtIndex:(NSInteger)index{
    
    // Rebuild the current playlist as array
#warning will add to a separate method
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    NSMutableArray* nowPlayingItems = [[NSMutableArray alloc] init];
    unsigned int i = 0;
    
    MPMediaItem* next = [iPodMusicPlayer nowPlayingItemAtIndex:i];
    while (next){
        [nowPlayingItems addObject:next];
    }
    
    // Remove the item
    [nowPlayingItems removeObjectAtIndex:index];
    
#warning incomplete method implementation
}

#pragma mark - Playing Collections & Queries

/// Play a song with given collection as the queue
+ (void) playSong:(MPMediaItem*)song QueueCollection:(MPMediaItemCollection*)collection{
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Temporarily turn off shuffle
    MPMusicShuffleMode oldShufMode = [iPodMusicPlayer shuffleMode];
    [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
    
    // Set playing queue and now playing item
    [iPodMusicPlayer setQueueWithItemCollection:collection];
    [iPodMusicPlayer setNowPlayingItem:song];
    
    // Turn shuffle back on, if it was on
    if (oldShufMode != MPMusicShuffleModeOff){
        [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    }
    
    [iPodMusicPlayer play];
    
}

/// Play a song with given query as the queue
+ (void) playSong:(MPMediaItem*)song QueueQuery:(MPMediaQuery*)query{
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Temporarily turn off shuffle
    MPMusicShuffleMode oldShufMode = [iPodMusicPlayer shuffleMode];
    [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
    
    // Set playing queue and now playing item
    [iPodMusicPlayer setQueueWithQuery:query];
    [iPodMusicPlayer setNowPlayingItem:song];
    
    // Turn shuffle back on, if it was on
    if (oldShufMode != MPMusicShuffleModeOff){
        [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    }
    
    [iPodMusicPlayer play];
    
}

/// Play the given collection as queue
+ (void) playCollection:(MPMediaItemCollection*)collection ForceShuffle:(BOOL)shuffle{
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Set playing queue
    [iPodMusicPlayer setQueueWithItemCollection:collection];
    
    // Turn on shuffle
    if (shuffle) [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    
    [iPodMusicPlayer play];
}

/// Play the given query as queue
+ (void) playQuery:(MPMediaQuery*)query ForceShuffle:(BOOL)shuffle{
    
    MPMusicPlayerController* iPodMusicPlayer = [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
    
    // Set playing queue
    [iPodMusicPlayer setQueueWithQuery:query];
    
    // Turn on shuffle
    if (shuffle) [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    
    [iPodMusicPlayer play];
}


@end
