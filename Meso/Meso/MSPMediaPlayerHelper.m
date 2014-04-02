//
//  MSPMediaQueryHelper.m
//  Meso
//
//  Created by Gun on 3/28/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPMediaPlayerHelper.h"
#import "MSPAppDelegate.h"
#import "MPMusicPlayerController+PrivateInterface.h"

@implementation MSPMediaPlayerHelper

#pragma mark - Initialization

/// Return the pre-configured iPod music player
+ (MPMusicPlayerController*)iPodMusicPlayer{
    
    // Get the default iPod player
    MPMusicPlayerController* iPod = [MPMusicPlayerController iPodMusicPlayer];
    
    // Tell the iPod to notify of any status changes, which will be handled in appropriate classes
    [iPod beginGeneratingPlaybackNotifications];
    
    // Disable the playbackstate cache as workaround for playbackstate bug
    // See: http://stackoverflow.com/questions/10118726/getting-wrong-playback-state-in-mp-music-player-controller-in-ios-5
    // For more information
    [iPod setUseCachedPlaybackState:NO];
    
    return iPod;
}

/// Return the shared music player inside this app's AppDelegate
+ (MPMusicPlayerController*)sharedPlayer{
    return [((MSPAppDelegate*)[[UIApplication sharedApplication] delegate]) sharedPlayer];
}

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
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)index];
}

/// Return an MPMediaItem in playing queue with offset from now playing item
/// Exmaple- An offset of 0 means the next song in queue
+ (MPMediaItem *)nowPlayingItemFromCurrentOffset:(NSInteger)offset{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    NSInteger nextItemIndex = [iPodMusicPlayer indexOfNowPlayingItem] + 1 + offset;
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)nextItemIndex];
}

/// Return the number of items left in the currently playing queue
+ (NSInteger)itemsLeftInPlayingQueue{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    return [iPodMusicPlayer numberOfItems] - ([iPodMusicPlayer indexOfNowPlayingItem] + 1);
}

/// Remove the item with given offset from now playing item from now playing queue
/// Offset of 0 means the next item in queue
/// Also maintains the playback state of the music player
+ (void) removeUpcomingItemAtOffset:(NSInteger)offset{
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    
    // Get the current playback state to be restored later
    NSInteger playbackIndex = [iPodMusicPlayer indexOfNowPlayingItem];
    MPMusicPlaybackState playbackState = [iPodMusicPlayer playbackState];
    NSTimeInterval playbackTime = [iPodMusicPlayer currentPlaybackTime];
    
    // Rebuild the current queue items as an array of media items
    NSUInteger numItems = [iPodMusicPlayer numberOfItems];
    NSMutableArray* newQueueArray = [[NSMutableArray alloc] initWithCapacity:numItems];
    // Loop through the upcoming items
    // Add the items to an array
    for (NSUInteger i = 0; i < numItems; i++) {
        [newQueueArray addObject:[iPodMusicPlayer nowPlayingItemAtIndex:i]];
    }
    
    // Remove unwanted object
    [newQueueArray removeObjectAtIndex:(playbackIndex + 1 + offset)];
    
    // Set the new queue as playing queue
    MPMediaItemCollection* newQueue = [[MPMediaItemCollection alloc] initWithItems:newQueueArray];
    [iPodMusicPlayer setQueueWithItemCollection:newQueue];
    
    // Restore playback state
    [iPodMusicPlayer setNowPlayingItem:[newQueue items][playbackIndex]];
    if (playbackState == MPMusicPlaybackStatePlaying) [iPodMusicPlayer play];
    [iPodMusicPlayer setCurrentPlaybackTime:playbackTime];
}

#pragma mark - Playing Collections & Queries

/// Play a song with given collection as the queue
+ (void) playSong:(MPMediaItem*)song QueueCollection:(MPMediaItemCollection*)collection{
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    
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
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    
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
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    
    // Set playing queue
    [iPodMusicPlayer setQueueWithItemCollection:collection];
    
    // Turn on shuffle
    if (shuffle) [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    
    [iPodMusicPlayer play];
}

/// Play the given query as queue
+ (void) playQuery:(MPMediaQuery*)query ForceShuffle:(BOOL)shuffle{
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    
    // Set playing queue
    [iPodMusicPlayer setQueueWithQuery:query];
    
    // Turn on shuffle
    if (shuffle) [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    
    [iPodMusicPlayer play];
}


@end
