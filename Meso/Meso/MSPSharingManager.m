//
//  MSPSharingManager.m
//  Meso
//
//  Created by Gun on 5/10/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPSharingManager.h"
#import "MSPConstants.h"
#import "MSPMediaPlayerHelper.h"

@implementation MSPSharingManager{
    // Private variables
    CBPeripheralManager* peripheralManager;
    dispatch_queue_t peripheralQueue;
    
    // Peripheral Manager
    CBMutableService* mesoService;
    CBMutableCharacteristic* mesoUUIDChar;
    CBMutableCharacteristic* mesoDataChar;
}

#pragma mark - Bluetooth Broadcasting

- (void)startAdvertising{
    // Start advertising your own data
    peripheralQueue = dispatch_queue_create("periqueue", NULL);
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralQueue];
    
}

/// Called when the device's Bluetooth state changed.
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    if ([peripheral state] == CBPeripheralManagerStatePoweredOn){
        
        // Generate UUIDs
        CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:UUID_BT_SERVICE];
        CBUUID* mesoUUIDUUID = [CBUUID UUIDWithString:UUID_BT_CHAR_UUID];
        CBUUID* mesoDataUUID = [CBUUID UUIDWithString:UUID_BT_CHAR_DATA];
        
        // Gather data required for broadcasting
        
        // Meso UUID identifying the device
        NSString* mesoUUID = [MSPSharingManager userUUID].UUIDString;
        NSData* mesoUUIDData = [mesoUUID dataUsingEncoding:NSUTF8StringEncoding];
        mesoService = [[CBMutableService alloc] initWithType:mesoServiceUUID primary:YES];
        
        
        
        
        mesoUUIDChar = [[CBMutableCharacteristic alloc] initWithType:mesoUUIDUUID
                                                          properties:CBCharacteristicPropertyRead
                                                               value:mesoUUIDData
                                                         permissions:CBAttributePermissionsReadable];
        
        mesoDataChar = [[CBMutableCharacteristic alloc] initWithType:mesoDataUUID
                                                          properties:CBCharacteristicPropertyRead
                                                               value:nil
                                                         permissions:CBAttributePermissionsReadable];
        
        
        // Set characterisitc to service
        [mesoService setCharacteristics:@[mesoUUIDChar, mesoDataChar]];
        
        // Publish Service
        [peripheralManager addService:mesoService];
        
        // Start advertising
        [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[mesoService.UUID], CBAdvertisementDataLocalNameKey : @"Meso Device"}];
    }
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    
    // Verify Characteristic
    if ([request.characteristic.UUID isEqual:mesoDataChar.UUID]){
        
        // Make sure requested data is in bounds
        if (request.offset > mesoDataChar.value.length){
            [peripheralManager respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        // Update Value on Characteristic
        // Metadata of...
        NSString* mesoMetaName = [MSPSharingManager userProfileName];                                       // Name
        NSNumber* mesoMetaAvatar = [NSNumber numberWithLong:[MSPSharingManager userProfileAvatarID]];       // Avatar
        NSString* mesoMetaMessage = [MSPSharingManager userProfileMessage];                                 // Personal Message
        NSNumber* mesoMetaNumMet = [NSNumber numberWithUnsignedLong:[MSPSharingManager userProfileNumMet]]; // Users Met
        NSArray* mesoMetaNowPlaying = [MSPMediaPlayerHelper nowPlayingItemAsArray];                         // Now playing song
        NSArray* mesoMetaMesoList = [MSPSharingManager userProfileMesoList];                                // User's shared playlist
        
        NSDictionary* mesoData = @{@"name": mesoMetaName,
                                   @"avatar": mesoMetaAvatar,
                                   @"message": mesoMetaMessage,
                                   @"nummet": mesoMetaNumMet,
                                   @"nowplay": mesoMetaNowPlaying,
                                   @"mesolist": mesoMetaMesoList};
        NSData* mesoDataData = [NSJSONSerialization dataWithJSONObject:mesoData options:0 error:nil];
        [mesoDataChar setValue:mesoDataData];
        
        // Respond to request
        request.value = [mesoDataChar.value subdataWithRange:NSMakeRange(request.offset, mesoDataChar.value.length - request.offset)];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
    
    // Otherwise the request failed
    [peripheralManager respondToRequest:request withResult:CBATTErrorRequestNotSupported];
}

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

/// Return User's Profile Avatar ID
+ (NSInteger)userProfileAvatarID{
    
    NSInteger avatarID = [[NSUserDefaults standardUserDefaults] integerForKey:@"MesoProfileAvatarID"];
    return avatarID;
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
    
    return YES;
}

/// Remove song at specified index from sharing list
+ (void)removeSongFromMesoList:(NSUInteger) index{
    NSMutableArray* sharingList = [self userProfileMesoList].mutableCopy;
    
    [sharingList removeObjectAtIndex:index];
    
    [[NSUserDefaults standardUserDefaults] setObject:sharingList forKey:@"MesoProfileMesoList"];
}

+(void)setUserProfileName:(NSString *)name{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"MesoProfileName"];

}

+(void)setUserProfileMessage:(NSString *)message{
    [[NSUserDefaults standardUserDefaults] setObject:message forKey:@"MesoProfileMessage"];

}

+ (void)setUserProfileAvatar:(NSInteger)avatarID{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:(long)avatarID] forKey:@"MesoProfileAvatarID"];
    
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

/// Return Avatar with given ID
+ (UIImage*)avatarWithID:(NSInteger) avatarID{
    
    NSString *imageToLoad = [NSString stringWithFormat:@"av%02ld", (long)avatarID];
    UIImage* image = [UIImage imageNamed:imageToLoad];
    return image;
}

@end
