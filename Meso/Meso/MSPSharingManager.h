//
//  MSPSharingManager.h
//  Meso
//
//  Created by Gun on 5/10/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSPSharingManager : NSObject

#pragma mark - User Profile

/// Return whether the user has their profile set up
+ (BOOL) profileIsSet;

/// Return User's Profile Name
+ (NSString*)userProfileName;

/// Return User's Profile Message
+ (NSString*)userProfileMessage;

/// Return User's Profile Avatar ID
+ (NSInteger)userProfileAvatarID;

/// Return the User's Sharing List
+ (NSArray*)userProfileMesoList;

/// Set User's Profile Name
+ (void)setUserProfileName:(NSString*)name;

/// Set User's Profile Message
+ (void)setUserProfileMessage:(NSString*)message;

/// Set User's Profile Avatar
+ (void)setUserProfileAvatar:(NSInteger)avatarID;

/// Return User's Meso UUID
+ (NSUUID*)userUUID;

/// Return User's Profile # of people met
+ (NSUInteger)userProfileNumMet;

/// Clear the user's sharing list
+ (void)clearUserProfileMesoList;

/// Add a song to the user's sharing list
/// Return whether the add was successful
+ (BOOL)addSongToMesoList:(NSArray*) song;

/// Remove song at specified index from sharing list
+ (void)removeSongFromMesoList:(NSUInteger) index;

#pragma mark - Database

/// Return the history of devices found
+ (NSDictionary*)devicesFound;

/// Return sorted array of uuid of devices found
+ (NSArray*)sortedDeviceUUIDs;

/// Add a new device to database
+ (void)addDeviceWithUUID:(NSUUID*)uuid PeerInfo:(NSDictionary*)info;

/// Clears database
+ (void)clearDatabase;

#pragma mark - Helpers

/// Return Avatar with given ID
+ (UIImage*)avatarWithID:(NSInteger) avatarID;

@end
