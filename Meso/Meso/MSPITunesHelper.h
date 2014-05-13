//
//  MSPITunesHelper.h
//  Meso
//
//  Created by Gun on 5/13/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MSPITunesHelper : NSObject

/////////////////////////////The json parsing for the apple search
+(NSDictionary*) appleSearchApi:(NSString*)artistName didGetSongName:(NSString*)songName;

+ (AVPlayer*)playPreviewSound:(NSDictionary*)data;

+ (UIImage*)artworkImage:(NSDictionary*)data;

+ (void)openITunesStore:(NSDictionary*)data;

@end
