//
//  MSPTableViewCell.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPTableViewCell.h"
#import "MSPConstants.h"
#import "MSPStringHelper.h"

@implementation MSPTableViewCell{
    BOOL hasThumb;
    BOOL hasString;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        hasThumb = NO;
        hasString = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addThumbnailWithImage:(UIImage*)image{
    // Add the given image as a subview shown as thumbnail
    // Replace the existing thumb if one already exists
    
    // Check if we already have a thumbnail
    if (hasThumb){
        UIImageView* customView = (UIImageView*)[self viewWithTag:TABLE_VIEW_CELL_THUMBNAIL_TAG];
        [customView setImage:image];
    }
    else{
        // Redraw in a custom view
        CGRect artFrame;
        NSString* cellID = [self reuseIdentifier];
        if ([cellID isEqualToString:@"idsongitemcompact"]){
            artFrame = CGRectMake(TABLE_VIEW_COMPACT_ALBUM_ART_PADDING,
                                  TABLE_VIEW_COMPACT_ALBUM_ART_PADDING,
                                  TABLE_VIEW_COMPACT_ALBUM_ART_WIDTH,
                                  TABLE_VIEW_COMPACT_ALBUM_ART_HEIGHT);
        }
        else { //Assume default
            artFrame = CGRectMake(TABLE_VIEW_ALBUM_ART_PADDING,
                                  TABLE_VIEW_ALBUM_ART_PADDING,
                                  TABLE_VIEW_ALBUM_ART_WIDTH,
                                  TABLE_VIEW_ALBUM_ART_HEIGHT);
        }
        
        UIImageView* customView = [[UIImageView alloc] initWithFrame:artFrame];
        [customView setImage:image];
        [customView setBounds:[customView frame]];
        [customView setContentMode:UIViewContentModeScaleAspectFill];
        [customView setClipsToBounds:YES];
        [customView setTag:TABLE_VIEW_CELL_THUMBNAIL_TAG];
        
        [self.contentView addSubview:customView];
        hasThumb = YES;
        
        [self setIndentationWidth:artFrame.size.width];
    }
    
}

- (void)addThumbnailWithMediaItemArtwork:(MPMediaItemArtwork*)artwork{
    // Add the given artwork as a subview shown as thumbnail
    // Replace the existing thumb if one already exists
    
    UIImage* artworkImage = [artwork imageWithSize:CGSizeMake(TABLE_VIEW_ALBUM_ART_WIDTH, TABLE_VIEW_ALBUM_ART_HEIGHT)];
    [self addThumbnailWithImage:artworkImage];
}

- (void)setSongInfo:(MPMediaItem*)song WithString:(NSString*)string ShowAlbum:(BOOL)showAlbum{
    // Use the given song as the data for the cell
    // Assuming the cell has appropriate styles
    
    // Grab song data
    // Title
    NSString* songTitle = [song valueForProperty:MPMediaItemPropertyTitle];
    // Artist
    NSString* songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
    // Album
    NSString* songAlbum = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
    // Artwork
    MPMediaItemArtwork* songArt = [song valueForProperty:MPMediaItemPropertyArtwork];
    // Unique Persistent ID for the song
    NSNumber* songPID = [song valueForProperty:MPMediaItemPropertyPersistentID];
    
    // Set cell data
    // Artwork
    if (showAlbum) [self addThumbnailWithMediaItemArtwork:songArt];
    // Title
    [[self textLabel] setText:songTitle];
    // Subtitle
    if (showAlbum){
        NSAttributedString* subtitle = [MSPStringHelper getAttributedSubtitleFromArtist:songArtist
                                                                                  Album:songAlbum
                                                                           WithFontSize:[[[self detailTextLabel] font] pointSize]
                                                                                  Color:[[self detailTextLabel] textColor]];
        [[self detailTextLabel] setAttributedText:subtitle];
    }
    else{
        [[self detailTextLabel] setText:songArtist];
    }
    
    // Optional string to set
    if (string){
        // Check if we already added the string
        if (hasString){
            UILabel* labelView = (UILabel*)[self viewWithTag:101];
            [labelView setText:string];
        }
        else{
            // Move text over
            [self setIndentationWidth:[self indentationWidth] + TABLE_VIEW_COMPACT_STRING_WIDTH + TABLE_VIEW_ALBUM_ART_PADDING];
            
            // Move artwork over
            UIImageView* thumbnailView = (UIImageView*)[self viewWithTag:TABLE_VIEW_CELL_THUMBNAIL_TAG];
            CGRect newFrame = [thumbnailView frame];
            newFrame.origin.x += (TABLE_VIEW_COMPACT_STRING_WIDTH + TABLE_VIEW_ALBUM_ART_PADDING);
            [thumbnailView setFrame:newFrame];
            
            // Make label and add as subview
            UILabel* labelView = [[UILabel alloc] initWithFrame:CGRectMake(TABLE_VIEW_ALBUM_ART_PADDING,
                                                                           TABLE_VIEW_ALBUM_ART_PADDING,
                                                                           TABLE_VIEW_COMPACT_STRING_WIDTH,
                                                                           TABLE_VIEW_COMPACT_ALBUM_ART_HEIGHT)];
            [labelView setText:string];
            [labelView setTag:TABLE_VIEW_CELL_STRING_TAG];
            [labelView setFont:[UIFont systemFontOfSize:TABLE_VIEW_COMPACT_STRING_FONT_SIZE]];
            [labelView setTextAlignment:NSTextAlignmentCenter];
            [labelView setAdjustsFontSizeToFitWidth:YES];
            [labelView setMinimumScaleFactor:0.5];
            [self.contentView addSubview:labelView];
            
            hasString = YES;
        }
    }
    
    // Metdata - PID
    [self setPID:songPID];

}

@end
