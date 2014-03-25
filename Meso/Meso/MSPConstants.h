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
extern NSInteger const TABLE_VIEW_SHUFFLE_ROW_HEIGHT;   // Row height for shuffle button in table view
extern NSInteger const TABLE_VIEW_SONG_ROW_HEIGHT;      // Row height for songs in table view

// UI Strings
extern NSString* const TABLE_VIEW_SONG_COUNT_FORMAT;    // Format of number of songs (eg. 9999 Songs)
extern NSString* const TABLE_VIEW_SUBTITLE_FORMAT;      // Format of subtitle in table view (eg. Artist - Album)
extern NSString* const NOWPLAYING_VIEW_SUBTITLE_FORMAT; // Format of subtitle in the now playing view
extern NSString* const STRING_UNKNOWN_ARTIST;           // String for unknown artist
extern NSString* const STRING_UNKNOWN_ALBUM;            // String for unknown album
extern NSString* const STRING_NOTHING_PLAYING;          // String to show when nothing is playing on now playing screen
extern NSString* const STRING_NOTHING_PLAYING_TIME;     // String to show on timers when nothing is playing

// Undocumented API Constants
extern NSString* const MSPMediaItemPropertySortTitle;               // Used to query song's alternate title
extern NSString* const MSPMediaPlaylistPropertyIsFolder;            // Used to query playlist's folder flag
extern NSString* const MSPMediaPlaylistPropertyParentPersistentID;  // Used to query playlist's PID

// File Names
extern NSString* const FILENAME_FILLBUTTON_PLAY;        // File name for play button image
extern NSString* const FILENAME_FILLBUTTON_PAUSE;       // File name for pause button image
extern NSString* const FILENAME_BUTTON_REPEAT;          // File name for repeat button image
extern NSString* const FILENAME_BUTTON_REPEATONE;       // File name for repeat one button image

// Blurring Performance Related
extern const char* const BLURRING_QUEUE_NAME;           // Queue label for blurring queue sent to GCD
extern NSInteger const BLURRED_IMAGE_CACHE_SIZE;        // The cache size for blurred images
extern NSInteger const BLURRED_IMAGE_DOWNSCALE_WIDTH;   // Album arts will be downscaled to this size before blurring
extern NSInteger const BLURRED_IMAGE_DOWNSCALE_HEIGHT;  // Album arts will be downscaled to this size before blurring
extern NSInteger const BLURRED_IMAGE_BLUR_RADIUS;       // The blur effect blur radius

// Other Numbers
extern float const FAST_SEEKING_DELAY;                  // Delay in seconds before fast seeking occurs on button held down
extern float const FAST_SEEKING_RATE;                   // The rate of fast seeking
extern float const MARQUEE_LABEL_RATE;                  // Rate at which marquee text moves
extern NSTimeInterval const NOWPLAYING_UPDATE_INTERVAL; // Rate at which elapsed time and progress bar updates