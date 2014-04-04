//
//  MSPConstants.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPConstants.h"

NSInteger const TABLE_VIEW_SONG_ROW_HEIGHT = 60;
NSInteger const TABLE_VIEW_ALBUM_ART_WIDTH = 50;
NSInteger const TABLE_VIEW_ALBUM_ART_HEIGHT = 50;
NSInteger const TABLE_VIEW_ALBUM_ART_PADDING = 5;
NSInteger const TABLE_VIEW_CELL_THUMBNAIL_TAG = 100;

NSInteger const TABLE_VIEW_COMPACT_SONG_ROW_HEIGHT = 50;
NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_WIDTH = 40;
NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_HEIGHT = 40;
NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_PADDING = 5;
NSInteger const TABLE_VIEW_CELL_STRING_TAG = 101;
NSInteger const TABLE_VIEW_COMPACT_STRING_WIDTH = 25;
CGFloat const TABLE_VIEW_COMPACT_STRING_FONT_SIZE = 12.0;

NSString* const TABLE_VIEW_SONG_COUNT_FORMAT = @"%ld Songs";
NSString* const STRING_UNKNOWN_ARTIST = @"Unknown Artist";
NSString* const STRING_UNKNOWN_ALBUM = @"Unknown Album";
NSString* const STRING_NOTHING_PLAYING = @"";
NSString* const STRING_NOTHING_PLAYING_TIME = @"--:--";

NSString* const MSPMediaItemPropertySortTitle = @"sortTitle";
NSString* const MSPMediaPlaylistPropertyIsFolder = @"isFolder";
NSString* const MSPMediaPlaylistPropertyParentPersistentID = @"parentPersistentID";

const char* const BLURRING_QUEUE_NAME = "imageblurringqueue";

NSInteger const BLURRED_IMAGE_CACHE_SIZE = 5;
NSInteger const BLURRED_IMAGE_DOWNSCALE_HEIGHT = 300;
NSInteger const BLURRED_IMAGE_DOWNSCALE_WIDTH = 300;
NSInteger const BLURRED_IMAGE_BLUR_RADIUS = 10;

float const FAST_SEEKING_DELAY = 1.0;
float const FAST_SEEKING_RATE = 2.0;
float const MARQUEE_LABEL_RATE = 30.0;
NSTimeInterval const NOWPLAYING_UPDATE_INTERVAL = 0.5;
