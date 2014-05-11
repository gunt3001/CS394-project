//
//  MSPShareMesoActivity.m
//  Meso
//
//  Created by Napat R on 15/4/2014.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPShareMesoActivity.h"
#import "MSPSharingManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MSPShareMesoActivity{
    MPMediaItem* itemToShare;
}

- (NSString *)activityType{
    return @"com.kmabwp.mesoshareactivity";
}

- (NSString *)activityTitle{
    return @"Add to Meso Playlist";
}

- (UIImage *)activityImage{
#warning Needs Image
    return [UIImage imageNamed:@"radar"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    // Assuming this class won't be used out of Up Next View Sharing
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems{
    // Store activity items
    itemToShare = activityItems[2];
}

+ (UIActivityCategory)activityCategory{
    return UIActivityCategoryShare;
}

- (void)performActivity{
    // Add song to Meso list
    NSString* title = [itemToShare valueForProperty:MPMediaItemPropertyTitle];
    NSString* artist = [itemToShare valueForProperty:MPMediaItemPropertyArtist];
    [MSPSharingManager addSongToMesoList:@[title, artist]];
    [self activityDidFinish:YES];
}

+ (MSPShareMesoActivity *)sharedActivity{
    
    static MSPShareMesoActivity* sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[MSPShareMesoActivity alloc] init];
    }
    
    return(sharedInstance);
}
@end
