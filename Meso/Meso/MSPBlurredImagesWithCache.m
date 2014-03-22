//
//  MSPBlurredImagesWithCache.m
//  Meso
//
//  Created by Gun on 22/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPBlurredImagesWithCache.h"
#import "UIImage+ImageEffects.h"
#import "MSPConstants.h"

@implementation MSPBlurredImagesWithCache

- (id)init{
    // Generate the playlist tree structure from iPod library
    
    self = [super init];
    if (self){
        _cache = [[NSMutableDictionary alloc] init];
        _history = [[NSMutableArray alloc] init];
    }
    return self;
}

- (UIImage *)getBlurredImageOfArt:(UIImage *)art WithPID:(NSNumber *)pid{
    // Return blurred version of the image
    // But tries to look up with PID first
    
    UIImage* blurredArt = [_cache objectForKey:pid];
    // If one exists in the cache
    if (blurredArt){
        return [_cache objectForKey:pid];
    }
    // Otherwise create the blurred version of the image
    else{
        UIImage* blurredArt = [art applyDarkEffect];
        
        // Check if we've reached the maximum cache size
        if ([_history count] >= BLURRED_IMAGE_CACHE_SIZE){
            
            // Remove the oldest item in the cache (first item in list)
            [_cache removeObjectForKey:[_history objectAtIndex:0]];
            [_history removeObjectAtIndex:0];
        }
        
        // Add the new image into cache
        [_cache setObject:blurredArt forKey:pid];
        [_history addObject:pid];
        
        return blurredArt;
    }
}

@end
