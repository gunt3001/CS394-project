//
//  MSPTableViewCell.h
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MSPTableViewCell : UITableViewCell

@property (nonatomic) NSNumber* PID;        // Media library PID

- (void)setSongInfo:(MPMediaItem*)song WithString:(NSString*)string ShowAlbum:(BOOL)showAlbum;

#pragma mark - Cell Masks
- (void)maskCellFromTop:(CGFloat)margin;

@end
