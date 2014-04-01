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

#pragma mark - Getting Media Entities

/// Return MPMediaPlaylist* of playlist with given pid
+ (MPMediaPlaylist*)playlistFromPID:(NSNumber*)pid;

/// Return MPMediaItem* of song with given pid
+ (MPMediaItem *)songFromPID:(NSNumber *)pid;

/// Return a query of all songs on the local device
+ (MPMediaQuery*) allSongsWithoutICloud;

#pragma mark - Currently Playing Queue

/// Return an MPMediaItem in playing queue with specified index
+ (MPMediaItem*) nowPlayingItemAtIndex:(NSInteger)index;

/// Return an MPMediaItem in playing queue with offset from now playing item
+ (MPMediaItem*) nowPlayingItemFromCurrentOffset:(NSInteger)offset;

/// Return the number of items left in the currently playing queue
+ (NSInteger) itemsLeftInPlayingQueue;

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
