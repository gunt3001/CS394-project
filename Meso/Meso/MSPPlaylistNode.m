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
        
        // Recursively generate the tree structure
        // Root node have ID of 0
        _pid = [NSNumber numberWithInt:0];
        
        _name = @"root";
        _children = [[NSMutableArray alloc] init];
        [self generateTreeWithArray:playlists];
    }
    return self;
}

- (id)initWithName:(NSString*)name Children:(NSMutableArray*)children Pid:(NSNumber*)pid{
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

/// Generate a tree structure from an array of playlist nodes
- (void) generateTreeWithArray:(NSArray*)playlists{
    
    // Temporary dictionary used to look up a node in the tree structure
    NSMutableDictionary* mapping = [[NSMutableDictionary alloc] init];
    
    // First loop - create node for all playlists (O(n))
    for (MPMediaPlaylist* eachPlaylist in playlists) {
        
        // Get data for the playlist
        NSString* name = [eachPlaylist valueForProperty:MPMediaPlaylistPropertyName];
        NSNumber* PID = [eachPlaylist valueForProperty:MPMediaPlaylistPropertyPersistentID];
        
        // Make a new node out of it
        MSPPlaylistNode* node = [[MSPPlaylistNode alloc] initWithName:name
                                                             Children:[[NSMutableArray alloc] init]
                                                                  Pid:PID];
        
        // Add to dictionary
        [mapping setObject:node forKey:PID];
        
    }
    
    // Second loop - generate tree structure
    for (MPMediaPlaylist* eachPlaylist in playlists) {
        
        // Get data for the playlist
        NSNumber* parentPID = [eachPlaylist valueForProperty:MSPMediaPlaylistPropertyParentPersistentID];
        NSNumber* PID = [eachPlaylist valueForProperty:MPMediaPlaylistPropertyPersistentID];
        
        // Parent PID must be casted to unsigned long long first
        // This is to fix a bug with Apple's private API
        parentPID = [NSNumber numberWithUnsignedLongLong:[parentPID unsignedLongLongValue]];
        
        // Check if the playlist is at root
        if ([parentPID isEqualToNumber:_pid]){
            
            // Add as children of root
            MSPPlaylistNode* node = [mapping objectForKey:PID];
            [_children addObject:node];
            
        }
        // Otherwise it's in a folder somewhere, add it as children of appropriate node
        else{
            
            MSPPlaylistNode* node = [mapping objectForKey:PID];
            MSPPlaylistNode* parentNode = [mapping objectForKey:parentPID];
            [[parentNode children] addObject:node];
            
        }
    }
}

@end

