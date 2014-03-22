//
//  MSPPlaylistsTree.h
//  Meso
//
//  Created by Gun on 21/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//  MSP Playlists Tree
//  This class is used to store the playlist folder structure
//  Generated from MPMediaPlaylist objects
//

#import <Foundation/Foundation.h>

@interface MSPPlaylistNode : NSObject

@property (nonatomic) NSString* name;       // Name
@property (nonatomic) NSArray* children;    // Playlists inside this playlist folder
@property (nonatomic) NSNumber* pid;        // Persistent ID

-(id) initAsRoot;
-(NSInteger) childrenCount;
-(BOOL) isFolder;

+ (NSArray*) findChildrenOf:(NSNumber*)pid In:(NSMutableArray*)playlists;

@end
