//
//  MSPAppDelegate.h
//  Meso
//
//  Created by Napat R on 4/3/2014.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MSPSharingManager.h"


@interface MSPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) MPMusicPlayerController* sharedPlayer;                // Application-wide music player
@property (nonatomic) MSPSharingManager* sharingManager;                    // Application-wide bluetooth advertiser
@end
