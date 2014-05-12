//
//  MSPMesoTableViewController.m
//  Meso
//
//  Created by Gun on 23/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LGBluetooth.h"
#import "MSPMesoTableViewController.h"
#import "MSPProfileViewController.h"
#import "MSPSharingManager.h"
#import "MSPConstants.h"
#import "MSPMediaPlayerHelper.h"

@interface MSPMesoTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelPersonalMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProfileName;
@property (weak, nonatomic) IBOutlet UILabel *labelProfileMet;

@end

@implementation MSPMesoTableViewController{
    // Private variables
    CBPeripheralManager* peripheralManager;
    dispatch_queue_t peripheralQueue;
    
    // Peripheral Manager
    CBMutableService* mesoService;
    CBMutableCharacteristic* mesoUUIDChar;
    CBMutableCharacteristic* mesoDataChar;
    
    // Timers
    NSTimer* searchTimer;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // On load of this tab, check if the user have set up his profile
    // If not, proceed to setup page
    if (![MSPSharingManager profileIsSet]){
        // TBD: Show Welcome page & Instructions
        
        [self performSegueWithIdentifier:@"segueProfileSetup" sender:self];
    }
    
    // Load Profile Info
    [self updateProfile];
    
    // Start advertising your own data
    peripheralQueue = dispatch_queue_create("periqueue", NULL);
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralQueue];
    
    // Set up search timer
    // Update at a constant time
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                     target:self
                                                   selector:@selector(fireTimer:)
                                                   userInfo:nil repeats:YES];
}

#pragma mark - Bluetooth Peripheral

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
        
        // Metadata of...
        NSString* mesoMetaName = [MSPSharingManager userProfileName];                                       // Name
        NSString* mesoMetaMessage = [MSPSharingManager userProfileMessage];                                 // Personal Message
        NSNumber* mesoMetaNumMet = [NSNumber numberWithUnsignedLong:[MSPSharingManager userProfileNumMet]]; // Users Met
        NSArray* mesoMetaNowPlaying = [MSPMediaPlayerHelper nowPlayingItemAsArray];                         // Now playing song
        NSArray* mesoMetaMesoList = [MSPSharingManager userProfileMesoList];                                // User's shared playlist
        
        NSDictionary* mesoData = @{@"name": mesoMetaName,
                                   @"message": mesoMetaMessage,
                                   @"nummet": mesoMetaNumMet,
                                   @"nowplay": mesoMetaNowPlaying,
                                   @"mesolist": mesoMetaMesoList};
        
        NSData* mesoDataData = [NSJSONSerialization dataWithJSONObject:mesoData options:0 error:nil];
        
        mesoUUIDChar = [[CBMutableCharacteristic alloc] initWithType:mesoUUIDUUID
                                                          properties:CBCharacteristicPropertyRead
                                                               value:mesoUUIDData
                                                         permissions:CBAttributePermissionsReadable];
        
        mesoDataChar = [[CBMutableCharacteristic alloc] initWithType:mesoDataUUID
                                                          properties:CBCharacteristicPropertyRead
                                                               value:mesoDataData
                                                         permissions:CBAttributePermissionsReadable];
        
        
        // Set characterisitc to service
        [mesoService setCharacteristics:@[mesoUUIDChar, mesoDataChar]];
        
        // Publish Service
        [peripheralManager addService:mesoService];
        
        // Start advertising
        [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[mesoService.UUID], CBAdvertisementDataLocalNameKey : @"Meso Device"}];
    }
    
}

#pragma mark - LGBluetooth

-(void) processPeripherals:(LGPeripheral*) peripheral{
    // Open connection to peripheral
    [peripheral connectWithCompletion:^(NSError *error) {
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                
                // Find Meso Service
                if ([service.UUIDString isEqualToString:UUID_BT_SERVICE.lowercaseString]) {
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        
                        __block NSString* peerUUID;
                        __block NSDictionary* peerData;
                        
                        for (LGCharacteristic* eachChar in characteristics){
                            // UUID
                            if ([eachChar.UUIDString isEqualToString:UUID_BT_CHAR_UUID.lowercaseString]){
                                
                                [eachChar readValueWithBlock:^(NSData *data, NSError *error) {
                                    // Make data
                                    NSString* peerUUIDString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    peerUUID = peerUUIDString;
                                    
                                    if (peerUUID && peerData)
                                        [self finishConnectionWithUUID:peerUUID Data:peerData Peripheral:peripheral];
                                }];
                            }
                            // Data
                            else if ([eachChar.UUIDString isEqualToString:UUID_BT_CHAR_DATA.lowercaseString]){
                                
                                [eachChar readValueWithBlock:^(NSData *data, NSError *error) {
                                    // Make data
                                    peerData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                    
                                    if (peerUUID && peerData)
                                        [self finishConnectionWithUUID:peerUUID Data:peerData Peripheral:peripheral];
                                }];
                            }
                        }
                        
                    }];
                }
            }
        }];
    }];
}

/// Close connection and add data to database
- (void) finishConnectionWithUUID:(NSString*)uuid Data:(NSDictionary*)data Peripheral:(LGPeripheral*) peripheral{
    
    // Disconnect
    [peripheral disconnectWithCompletion:nil];
    
    // Add data to database
    [MSPSharingManager addDeviceWithUUID:[[NSUUID alloc] initWithUUIDString:uuid] PeerInfo:data];
    [_deviceTable reloadData];
    [self updateProfile];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[MSPSharingManager devicesFound] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idpeeritem" forIndexPath:indexPath];
    
    // Configure the cell...
    NSUUID* key = [[MSPSharingManager sortedDeviceUUIDs] objectAtIndex:[indexPath row]];
    NSDictionary* peerInfo = [[MSPSharingManager devicesFound] objectForKey:key];
    [[cell textLabel] setText:[peerInfo objectForKey:@"name"]];
    [[cell detailTextLabel] setText:[peerInfo objectForKey:@"message"]];
    
    return cell;
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"segueProfileSetup"]){
         [(MSPProfileViewController*)segue.destinationViewController setPeopleViewController:self];
     }
 }


#pragma mark - Scanning

- (IBAction)buttonRefresh:(id)sender {
    [self scanPeripherals:4 Notify:YES];
}

- (void)fireTimer:(NSTimer*)timer{
    [self scanPeripherals:4 Notify:NO];
}

- (void)scanPeripherals:(NSUInteger)interval Notify:(BOOL)notify{
    // Start scanning for peripherals
    // Process the peripherals found after given interval in seconds
    
    // First, verify the bluetooth state
    if ([LGCentralManager sharedInstance].manager.state != CBCentralManagerStatePoweredOn){
        
        if (notify){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Unavailable"
                                                            message:@"Make sure your device is compatible with Bluetooth 4.0 and Bluetooth is powered on."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        return;
    }
    
    // Temporarily replace the button
    UIBarButtonItem* oldButton = self.navigationItem.leftBarButtonItem;
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self.navigationItem setLeftBarButtonItem:barButton];
    [activityIndicator startAnimating];
    
    // Start searching
    CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:UUID_BT_SERVICE];
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:interval services:@[mesoServiceUUID] options:nil completion:^(NSArray *peripherals)
     {
         for (LGPeripheral* eachPeri in peripherals) {
             [self processPeripherals:eachPeri];
         }
         
         [self.navigationItem setLeftBarButtonItem:oldButton];
     }];
}

#pragma mark - Helper functions

- (void) updateProfile{
    
    // Load Profile Info
    [_labelProfileName setText:[MSPSharingManager userProfileName]];
    [_labelPersonalMessage setText:[MSPSharingManager userProfileMessage]];
    [_labelProfileMet setText:[NSString stringWithFormat:@"Met %ld People", (long)[MSPSharingManager userProfileNumMet]]];
    UIImage* avatar = [MSPSharingManager avatarWithID:[MSPSharingManager userProfileAvatarID]];
    if (avatar){
        [_imageAvatar setImage:avatar];
    }
}

@end
