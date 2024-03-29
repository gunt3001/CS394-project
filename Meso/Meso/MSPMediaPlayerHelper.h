//
//  MSPMediaQueryHelper.h
//  Meso
//
//  Created by Gun on 3/28/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//
//  A class to help with querying and playing media items
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MSPMediaPlayerHelper : NSObject

#pragma mark - Initialization

/// Return the pre-configured iPod music player
+ (MPMusicPlayerController*)initiPodMusicPlayer;

/// Return the shared music player inside this app's AppDelegate
+ (MPMusicPlayerController*)sharedPlayer;

#pragma mark - Getting Media Entities

/// Return MPMediaPlaylist* of playlist with given pid
+ (MPMediaPlaylist*)playlistFromPID:(NSNumber*)pid;

/// Return MPMediaItem* of song with given pid
+ (MPMediaItem *)songFromPID:(NSNumber *)pid;

/// Return a query of all songs on the local device
+ (MPMediaQuery*) allSongsWithoutICloud;

#pragma mark - Currently Playing Queue

/// Return the currently playing song as array of title and artist
+ (NSArray*) nowPlayingItemAsArray;

/// Return an MPMediaItem in playing queue with specified index
+ (MPMediaItem*) nowPlayingItemAtIndex:(NSInteger)index;

/// Return an MPMediaItem in playing queue with offset from now playing item
+ (MPMediaItem*) nowPlayingItemAfterCurrentWithOffset:(NSInteger)offset;
+ (MPMediaItem*) nowPlayingItemBeforeCurrentWithOffset:(NSInteger)offset;

/// Return the number of items left in the currently playing queue
+ (NSInteger) itemsLeftInPlayingQueue;

/// Return the items in currently playing song's album as Query
+ (MPMediaQuery*)itemsInCurrentSongAlbum;

/// Play the song at specified index in queue
+ (void)playItemAtIndex:(NSInteger)index;

/// Replace current queue with a subset of it using specified indexes
/// Indexes given are in NSNumber*
+ (void)setQueueWithSubsetIndexes:(NSArray*)indexes;

#pragma mark - Playing Collections & Queries

/// Play a song with given collection as the queue
+ (void) playSong:(MPMediaItem*)song QueueCollection:(MPMediaItemCollection*)collection;

/// Play a song with given query as the queue
+ (void) playSong:(MPMediaItem*)song QueueQuery:(MPMediaQuery*)query;

/// Play the given collection as queue
+ (void) playCollection:(MPMediaItemCollection*)collection ForceShuffle:(BOOL)shuffle;

/// Play the given query as queue
+ (void) playQuery:(MPMediaQuery*)query ForceShuffle:(BOOL)shuffle;

@end
