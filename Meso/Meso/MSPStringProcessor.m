//
//  MSPStringProcessor.m
//  Meso
//
//  Created by Gun on 22/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPStringProcessor.h"
#import "MSPConstants.h"

@implementation MSPStringProcessor

+ (NSAttributedString *)getAttributedSubtitleFromArtist:(NSString *)artist Album:(NSString *)album WithFontSize:(CGFloat)fontSize Color:(UIColor*)color{
    // Create an attributed string of format "Artist Album" with Artist bolded
    
    UIFont* boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont* normalFont = [UIFont systemFontOfSize:fontSize];
    
    // Create attributes
    NSDictionary* boldAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                boldFont, NSFontAttributeName,
                                color, NSForegroundColorAttributeName, nil];
    NSDictionary* normalAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                normalFont, NSFontAttributeName, nil];
    
    // Create a string with regular attributes
    // If either of them is nil, replace with unknown artist/album
    if (!artist) artist = STRING_UNKNOWN_ARTIST;
    if (!album) album = STRING_UNKNOWN_ALBUM;
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:[NSString stringWithFormat:@"%@ %@", artist, album]
                                                   attributes:normalAttr];
    
    // Bold the artist part
    [attributedString setAttributes:boldAttr range:NSMakeRange(0, [artist length])];
    
    return attributedString;
}

@end
