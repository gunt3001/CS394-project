//
//  MSPPlaylistsTree.m
//  Meso
//
//  Created by Gun on 21/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPlaylistNode.h"
#import "MSPConstants.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MSPPlaylistNode

- (id)initAsRoot{
    // Generate the playlist tree structure from iPod library
    
    self = [super init];
    if (self){
        // Query everything from iPod Library
        MPMediaQuery* playlistsQuery = [MPMediaQuery playlistsQuery];
        NSArray* playlists = [playlistsQuery collections];
        NSMutableArray* workingPlaylists = [[NSMutableArray alloc] initWithArray:playlists];
        
        // Recursively generate the tree structure
        // Root node have ID of 0
        _pid = [NSNumber numberWithInt:0];
        
        _name = @"root";
        _children = [MSPPlaylistNode findChildrenOf:_pid In:workingPlaylists];
    }
    return self;
}

- (id)initWithName:(NSString*)name Children:(NSArray*)children Pid:(NSNumber*)pid{
    self = [super init];
    if (self){
        _name = name;
        _children = children;
        _pid = pid;
    }
    return self;
}

- (BOOL)isFolder{
    // Playlist is a folder if children count >= 1
    return [_children count] != 0;
}

- (NSInteger)childrenCount{
    // Return number of playlists in this folder
    return [_children count];
}

+ (NSArray*) findChildrenOf:(NSNumber*)pid In:(NSMutableArray*)playlists{
    // Return the array of children playlist of the given persistent id
    
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
     
    // Iterate through the playlist to find their children recursively
    for (MPMediaPlaylist* eachPlaylist in playlists) {
        NSString* eachName = [eachPlaylist valueForProperty:MPMediaPlaylistPropertyName];
        NSNumber* eachParentPID = [eachPlaylist valueForProperty:MSPMediaPlaylistPropertyParentPersistentID];
        NSNumber* eachPID = [eachPlaylist valueForProperty:MPMediaPlaylistPropertyPersistentID];
        
        // Parent PID must be casted to unsigned long long first
        // This is to fix a bug with Apple's private API
        eachParentPID = [NSNumber numberWithUnsignedLongLong:[eachParentPID unsignedLongLongValue]];
        
        if ([eachParentPID isEqualToNumber:pid]){
            // if we found a child for this playlist, create our own MSPPlaylistsTree object and add it to return list
            MSPPlaylistNode* child = [[MSPPlaylistNode alloc]
                                       initWithName:eachName
                                       Children:[MSPPlaylistNode findChildrenOf:eachPID In:playlists]
                                       Pid:eachPID];
            [returnArray addObject:child];
        }

    }
    return returnArray;
}

@end

