//
//  MSPSharingManager.m
//  Meso
//
//  Created by Gun on 5/10/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPSharingManager.h"

@implementation MSPSharingManager

/// Return whether the user has their profile set up
+ (BOOL)profileIsSet{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"]){
        return YES;
    }
    return NO;
}

/// Return User's Profile Name
+ (NSString*)userProfileName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"];
}

/// Return User's Profile Message
+ (NSString*)userProfileMessage{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileMessage"];
}

/// Return User's Profile Avatar
/// nil if none exists
+ (UIImage*)userProfileAvatar{
    
    NSString* imagePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileAvatar"];
    if (imagePath){
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    }
    else{
        return nil;
    }
}

+(void)setUserProfileName:(NSString *)name{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"MesoProfileName"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+(void)setUserProfileMessage:(NSString *)message{
    [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"MesoProfileMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (void)setUserProfileAvatar:(UIImage *)image{
    if (!image){
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MesoProfileAvatar"];
    }
    else{
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        NSString *imagePath = [self documentsPathForFileName:@"avatar.jpg"];
        // Write image data to user's folder
        [imageData writeToFile:imagePath atomically:YES];
        // Store path in NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"MesoProfileAvatar"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Helpers

+ (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
