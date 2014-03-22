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

- (UIImage *)getBlurredImageOfArt:(UIImage *)art WithPID:(NSNumber *)albumPid{
    // Return blurred version of the image
    // But tries to look up with PID first
    
    UIImage* blurredArt = [_cache objectForKey:albumPid];
    // If one exists in the cache
    if (blurredArt){
        return [_cache objectForKey:albumPid];
    }
    // Otherwise create the blurred version of the image
    else{
        // Resize image to smaller resolution for faster processing
        art = [self imageWithImage:art scaledToSize:CGSizeMake(BLURRED_IMAGE_DOWNSCALE_WIDTH, BLURRED_IMAGE_DOWNSCALE_HEIGHT)];
        
        UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
        UIImage* blurredArt = [art applyBlurWithRadius:BLURRED_IMAGE_BLUR_RADIUS
                                             tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        
        // Check if we've reached the maximum cache size
        if ([_history count] >= BLURRED_IMAGE_CACHE_SIZE){
            // Remove the oldest item in the cache (first item in list)
            [_cache removeObjectForKey:[_history objectAtIndex:0]];
            [_history removeObjectAtIndex:0];
        }
        
        // Add the new image into cache
        [_cache setObject:blurredArt forKey:albumPid];
        [_history addObject:albumPid];
        
        return blurredArt;
    }
}

#pragma mark - helper functions

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // Resizing UIImage
    // Code from http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
