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

float const FAST_SEEKING_DELAY = 1.0;
float const FAST_SEEKING_RATE = 2.0;
float const MARQUEE_LABEL_RATE = 30.0;
NSTimeInterval const NOWPLAYING_UPDATE_INTERVAL = 0.5;

NSString* const UUID_BT_SERVICE = @"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A";
NSString* const UUID_BT_CHAR_UUID = @"724E6C05-9820-4951-B3CA-DE2737538166";
NSString* const UUID_BT_CHAR_DATA = @"221D02CA-A308-4357-8471-AEA2833F23D1";
