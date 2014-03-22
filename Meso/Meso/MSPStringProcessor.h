//
//  MSPStringProcessor.h
//  Meso
//
//  Created by Gun on 22/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//
//  MSPStringProcessor
//  A collection of functions to create formatted NSString or NSAttributedString around the app
//

#import <Foundation/Foundation.h>

@interface MSPStringProcessor : NSObject

+ (NSAttributedString *)getAttributedSubtitleFromArtist:(NSString *)artist Album:(NSString *)album WithFontSize:(CGFloat)fontSize Color:(UIColor*)color;

@end
