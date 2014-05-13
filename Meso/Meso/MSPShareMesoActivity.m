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
    return [UIImage imageNamed:@"ActivityIcon"];
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
    if (![MSPSharingManager addSongToMesoList:@[title, artist]]){
        // Adding failed, list is already full
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sharing List Full"
                                                        message:@"Sharing list is limited to 5 songs. Please go to your profile and remove some songs first."
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it."
                                              otherButtonTitles:nil];
        [alert show];
    }
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
