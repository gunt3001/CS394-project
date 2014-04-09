//
//  MSPConstants.h
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

// Table Views
extern NSInteger const TABLE_VIEW_ALBUM_ART_WIDTH;      // Width for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_ALBUM_ART_HEIGHT;     // Height for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_ALBUM_ART_PADDING;    // Padding for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_CELL_THUMBNAIL_TAG;   // Tag for album art custom view in table view cell
extern NSInteger const TABLE_VIEW_SONG_ROW_HEIGHT;      // Row height for songs in table view
// Compact Version
extern NSInteger const TABLE_VIEW_COMPACT_SONG_ROW_HEIGHT;      // Row height for songs in table view
extern NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_WIDTH;      // Width for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_HEIGHT;     // Height for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_COMPACT_ALBUM_ART_PADDING;    // Padding for album art thumbnail in table view
extern NSInteger const TABLE_VIEW_CELL_STRING_TAG;              // Tag for optional string in compact cell
extern NSInteger const TABLE_VIEW_COMPACT_STRING_WIDTH;         // Width of optional string label in compact cell
extern CGFloat const TABLE_VIEW_COMPACT_STRING_FONT_SIZE;       // Font size of optional string label in compact cell

// UI Strings
extern NSString* const TABLE_VIEW_SONG_COUNT_FORMAT;    // Format of number of songs (eg. 9999 Songs)
extern NSString* const STRING_UNKNOWN_ARTIST;           // String for unknown artist
extern NSString* const STRING_UNKNOWN_ALBUM;            // String for unknown album
extern NSString* const STRING_NOTHING_PLAYING;          // String to show when nothing is playing on now playing screen
extern NSString* const STRING_NOTHING_PLAYING_TIME;     // String to show on timers when nothing is playing

// Undocumented API Constants
extern NSString* const MSPMediaItemPropertySortTitle;               // Used to query song's alternate title
extern NSString* const MSPMediaPlaylistPropertyIsFolder;            // Used to query playlist's folder flag
extern NSString* const MSPMediaPlaylistPropertyParentPersistentID;  // Used to query playlist's PID

// Other Numbers
extern float const FAST_SEEKING_DELAY;                  // Delay in seconds before fast seeking occurs on button held down
extern float const FAST_SEEKING_RATE;                   // The rate of fast seeking
extern float const MARQUEE_LABEL_RATE;                  // Rate at which marquee text moves
extern NSTimeInterval const NOWPLAYING_UPDATE_INTERVAL; // Rate at which elapsed time and progress bar updates
