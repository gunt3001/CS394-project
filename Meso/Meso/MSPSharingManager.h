//
//  MSPSharingManager.h
//  Meso
//
//  Created by Gun on 5/10/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSPSharingManager : NSObject

/// Return whether the user has their profile set up
+ (BOOL) profileIsSet;

/// Return User's Profile Name
+ (NSString*)userProfileName;

/// Return User's Profile Message
+ (NSString*)userProfileMessage;

/// Return User's Profile Avatar
/// nil if none exists
+ (UIImage*)userProfileAvatar;

/// Set User's Profile Name
+ (void)setUserProfileName:(NSString*)name;

/// Set User's Profile Message
+ (void)setUserProfileMessage:(NSString*)message;

/// Set User's Profile Avatar
+ (void)setUserProfileAvatar:(UIImage*)image;

@end
