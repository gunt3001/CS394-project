//
//  MSPAppDelegate.m
//  Meso
//
//  Created by Napat R on 4/3/2014.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPAppDelegate.h"
#import "MSPMediaPlayerHelper.h"
#include "TargetConditionals.h"

@implementation MSPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Re-set global tint color as a workaround for iOS 7.1 bug
    // where global tint is not applied correctly when using storyboard
    // Please see https://devforums.apple.com/message/949636 for more information
    [[self window] setTintColor:[UIColor brownColor]];
    
    
    // Warn when running in simulator
    if (TARGET_IPHONE_SIMULATOR){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Simulator Unsupported"
                                                        message:@"This app is designed to run on a real device with music library. It won't function inside a simulator."
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it."
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        // Initialize the global music player
        _sharedPlayer = [MSPMediaPlayerHelper initiPodMusicPlayer];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Refresh the playback state. This will run the music app if it is not running
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [_sharedPlayer playbackState];
    });
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
