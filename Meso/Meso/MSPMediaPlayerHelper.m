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
+ (MPMusicPlayerController*)initiPodMusicPlayer{
    
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

+ (NSArray *)nowPlayingItemAsArray{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    NSString* title = [[iPodMusicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
    NSString* artist = [[iPodMusicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyArtist];
    if (!title || !artist) return @[];
    return @[title, artist];
}

/// Return an MPMediaItem in playing queue with specified index
+ (MPMediaItem *)nowPlayingItemAtIndex:(NSInteger)index{
    
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)index];
}

/// Return an MPMediaItem in playing queue with offset from now playing item
/// Exmaple- An offset of 0 means the next song in queue
+ (MPMediaItem *)nowPlayingItemAfterCurrentWithOffset:(NSInteger)offset{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    NSInteger nextItemIndex = [iPodMusicPlayer indexOfNowPlayingItem] + 1 + offset;
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)nextItemIndex];
}

/// Return an MPMediaItem in playing queue with offset from now playing item
/// Exmaple- An offset of 0 means the previous song in queue
+ (MPMediaItem *)nowPlayingItemBeforeCurrentWithOffset:(NSInteger)offset{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    NSInteger prevItemIndex = [iPodMusicPlayer indexOfNowPlayingItem] - 1 - offset;
    return [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned)prevItemIndex];
}

/// Return the number of items left in the currently playing queue
+ (NSInteger)itemsLeftInPlayingQueue{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    return [iPodMusicPlayer numberOfItems] - ([iPodMusicPlayer indexOfNowPlayingItem] + 1);
}

/// Return the items in currently playing song's album as Query
+ (MPMediaQuery*)itemsInCurrentSongAlbum{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    NSNumber* albumPID = [[iPodMusicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyAlbumPersistentID];
    MPMediaQuery* albumQuery = [MPMediaQuery albumsQuery];
    [albumQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:albumPID forProperty:MPMediaItemPropertyAlbumPersistentID]];
    return albumQuery;
}

/// Play the song at specified index in queue
+ (void)playItemAtIndex:(NSInteger)index{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];
    MPMediaItem* target = [iPodMusicPlayer nowPlayingItemAtIndex:(unsigned int)index];
    [iPodMusicPlayer setNowPlayingItem:target];
    [iPodMusicPlayer play];
}

/// Replace current queue with a subset of it using specified indexes
/// Indexes given are in NSNumber*
+ (void)setQueueWithSubsetIndexes:(NSArray*)indexes{
    MPMusicPlayerController* iPodMusicPlayer = [MSPMediaPlayerHelper sharedPlayer];

    // Make a new queue
    NSMutableArray* newQueue = [[NSMutableArray alloc] init];
    
    // Add currently playing item
    [newQueue addObject:[iPodMusicPlayer nowPlayingItem]];
    
    // Plus the items at specified indexes
    for (NSNumber* index in indexes) {
        // Excluding now playing item
        if (index.integerValue == [iPodMusicPlayer indexOfNowPlayingItem]) continue;
        
        [newQueue addObject:[iPodMusicPlayer nowPlayingItemAtIndex:index.unsignedIntValue]];
    }
    
    // Set the new queue as playing queue
    // Turn off shuffle
    MPMusicPlaybackState originalPlaybackState = [iPodMusicPlayer playbackState];
    NSTimeInterval originalPlaybackTime = [iPodMusicPlayer currentPlaybackTime];
    [iPodMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
    
    MPMediaItemCollection* newQueueCollection = [[MPMediaItemCollection alloc] initWithItems:newQueue];
    [iPodMusicPlayer setQueueWithItemCollection:newQueueCollection];
    
    // Restore playback state
    [iPodMusicPlayer setNowPlayingItem:[newQueueCollection items][0]];
    if (originalPlaybackState == MPMusicPlaybackStatePlaying) [iPodMusicPlayer play];
    [iPodMusicPlayer setCurrentPlaybackTime:originalPlaybackTime];
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
