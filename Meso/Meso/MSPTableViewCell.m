//
//  MSPTableViewCell.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPTableViewCell.h"
#import "MSPConstants.h"

@implementation MSPTableViewCell{
    BOOL hasThumb;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        hasThumb = NO;
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
        UIImageView* customView = [[UIImageView alloc] initWithFrame:CGRectMake(TABLE_VIEW_ALBUM_ART_PADDING,
                                                                                TABLE_VIEW_ALBUM_ART_PADDING,
                                                                                TABLE_VIEW_ALBUM_ART_WIDTH,
                                                                                TABLE_VIEW_ALBUM_ART_HEIGHT)];
        [customView setImage:image];
        [customView setBounds:[customView frame]];
        [customView setContentMode:UIViewContentModeScaleAspectFill];
        [customView setClipsToBounds:YES];
        [customView setTag:TABLE_VIEW_CELL_THUMBNAIL_TAG];
        
        [self addSubview:customView];
        hasThumb = YES;
    }
    
}

- (void)addThumbnailWithMediaItemArtwork:(MPMediaItemArtwork*)artwork{
    // Add the given artwork as a subview shown as thumbnail
    // Replace the existing thumb if one already exists
    
    UIImage* artworkImage = [artwork imageWithSize:CGSizeMake(TABLE_VIEW_ALBUM_ART_WIDTH, TABLE_VIEW_ALBUM_ART_HEIGHT)];
    [self addThumbnailWithImage:artworkImage];
}

@end
