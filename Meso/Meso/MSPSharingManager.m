//
//  MSPSharingManager.m
//  Meso
//
//  Created by Gun on 5/10/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPSharingManager.h"

@implementation MSPSharingManager

#pragma mark - User Profile

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

/// Return User's Profile # of people met
+ (NSUInteger)userProfileNumMet{
    return [self devicesDatabase].count;
}

/// Return the User's Sharing List
+ (NSArray*)userProfileMesoList{
    NSArray* sharingList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"MesoProfileMesoList"];
    if (!sharingList) sharingList = @[];
    return sharingList;
}

/// Clear the user's sharing list
+ (void)clearUserProfileMesoList{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MesoProfileMesoList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// Add a song to the user's sharing list
/// Return whether the add was successful
+ (BOOL)addSongToMesoList:(NSArray*) song{
    NSArray* list = [self userProfileMesoList];
    
    // Limit to 5 songs
    if (list.count == 5) return NO;
    
    NSMutableArray* sharingList = list.mutableCopy;
    [sharingList addObject:song];
    
    [[NSUserDefaults standardUserDefaults] setObject:sharingList forKey:@"MesoProfileMesoList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

/// Remove song at specified index from sharing list
+ (void)removeSongFromMesoList:(NSUInteger) index{
    NSMutableArray* sharingList = [self userProfileMesoList].mutableCopy;
    
    [sharingList removeObjectAtIndex:index];
    
    [[NSUserDefaults standardUserDefaults] setObject:sharingList forKey:@"MesoProfileMesoList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

+ (NSUUID*)userUUID{
    NSString* uuidString = [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileUUID"];
    if (!uuidString){
        // If one doesn't exist, generate one
        NSUUID* uuid = [NSUUID UUID];
        
        // Save to userdefaults
        [[NSUserDefaults standardUserDefaults] setObject:uuid.UUIDString forKey:@"MesoProfileUUID"];
        
        return uuid;
    }
    else{
        return [[NSUUID alloc] initWithUUIDString:uuidString];
    }
}

#pragma mark - Database

/// Returns the database
/// Initialize it if necessary
+ (NSMutableDictionary*)devicesDatabase{
    static NSMutableDictionary* discoveredDevices;
    
    // First try to load from saved settings
    if (!discoveredDevices){
        discoveredDevices = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MesoDevicesDatabase"]];
    }
    
    // If still not available, initialze a new database
    if (!discoveredDevices){
        discoveredDevices = [[NSMutableDictionary alloc] init];
    }
    
    return discoveredDevices;
}

/// Save Database
+ (void)saveDatabase{
    [[NSUserDefaults standardUserDefaults] setObject:[self devicesDatabase] forKey:@"MesoDevicesDatabase"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)devicesFound{
    return [self devicesDatabase];
}

+ (NSArray*)sortedDeviceUUIDs{
    return [[self devicesDatabase] keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* obj1Name = [(NSDictionary*)obj1 objectForKey:@"keydevicename"];
        NSString* obj2Name = [(NSDictionary*)obj2 objectForKey:@"keydevicename"];
        return [obj1Name compare:obj2Name];
    }];
}

+(void)addDeviceWithUUID:(NSUUID *)uuid PeerInfo:(NSDictionary *)info{
    [[self devicesDatabase] setObject:info forKey:[uuid UUIDString]];
    [self saveDatabase];
}

/// Clears database
+ (void)clearDatabase{
    [[self devicesDatabase] removeAllObjects];
    [self saveDatabase];
}

#pragma mark - Helpers

+ (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
