//
//  MSPPlaylistsTableViewController.h
//  Meso
//
//  Created by Gun on 21/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPlaylistNode.h"
#import <UIKit/UIKit.h>

@interface MSPPlaylistsTableViewController : UITableViewController

@property (nonatomic) MSPPlaylistNode* playlistTree;
@property (nonatomic) NSNumber* playlistPID;

@end
