//
//  MPMusicPlayerController+CurrentQueue.h
//  Meso
//
//  Created by Gun on 4/1/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//  Category to use Apple's Private API on MPMusicPlayerController
//  Compatibility checked as of iOS 7.1
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMusicPlayerController (CurrentQueue)

/// Return the MPMediaItem* in current playing queue at specified index
-(id)nowPlayingItemAtIndex:(unsigned)index;

/// Return the number of items in current playing queue
- (unsigned int)numberOfItems;

@end
