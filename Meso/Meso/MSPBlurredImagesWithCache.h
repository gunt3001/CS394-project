//
//  MSPBlurredImagesWithCache.h
//  Meso
//
//  Created by Gun on 22/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//
//  A class to cache recently used album art images for faster processing
//

#import <Foundation/Foundation.h>

@interface MSPBlurredImagesWithCache : NSObject

@property (nonatomic) NSMutableDictionary* cache;       // Cache
@property (nonatomic) NSMutableArray* history;          // Ordering, used to remove oldest element

- (UIImage*) getBlurredImageOfArt:(UIImage*)art WithPID:(NSNumber*)pid;

@end
