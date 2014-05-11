//
//  MSPMesoTableViewController.m
//  Meso
//
//  Created by Gun on 23/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MSPMesoTableViewController.h"
#import "LGBluetooth.h"
#import "MSPProfileViewController.h"
#import "MSPSharingManager.h"

@interface MSPMesoTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelPersonalMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProfileName;

@end

@implementation MSPMesoTableViewController{
    // Private variables
    CBPeripheralManager* peripheralManager;
    dispatch_queue_t peripheralQueue;
    
    // Peripheral Manager
    CBMutableService* mesoService;
    CBMutableCharacteristic* nowPlayingChar;
    CBMutableCharacteristic* deviceNameChar;
    CBMutableCharacteristic* mesoUUIDChar;
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
    
    // Make sample data
    NSUUID* sampleDevice = [[NSUUID alloc] initWithUUIDString:@"68753A44-4D6F-1226-9C60-0050E4C00068"];
    NSDictionary* peer = [MSPMesoTableViewController makePeerItemFromName:@"Device Name" NowPlayingItem:@"Some Song"];
    [MSPSharingManager addDeviceWithUUID:sampleDevice PeerInfo:peer];
    [_deviceTable reloadData];
     
    
    // Start advertising your own data
    peripheralQueue = dispatch_queue_create("periqueue", NULL);
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralQueue];
}

#pragma mark - Bluetooth Peripheral

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    if ([peripheral state] == CBPeripheralManagerStatePoweredOn){
        
        // Generate UUIDs
        CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A"];
        CBUUID* mesoNowPlayingUUID = [CBUUID UUIDWithString:@"A4055D4E-CAEA-4BF3-8FDC-62EA5621D32B"];
        CBUUID* mesoDeviceNameUUID = [CBUUID UUIDWithString:@"7404CEA2-B789-4533-8AE7-A551488C2C84"];
        CBUUID* mesoUUIDUUID = [CBUUID UUIDWithString:@"724E6C05-9820-4951-B3CA-DE2737538166"];
        
        // Create Characteristic
        MPMusicPlayerController* ipod = [MPMusicPlayerController iPodMusicPlayer];
        MPMediaItem* nowplaying = [ipod nowPlayingItem];
        NSString* nowplayingtitle = [nowplaying valueForProperty:MPMediaItemPropertyTitle];
        NSData* nowplayingdata = [nowplayingtitle dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* deviceName = [[UIDevice currentDevice] name];
        NSData* deviceNameData = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* mesoUUID = [MSPSharingManager userUUID].UUIDString;
        NSData* mesoUUIDData = [mesoUUID dataUsingEncoding:NSUTF8StringEncoding];
        
        nowPlayingChar = [[CBMutableCharacteristic alloc] initWithType:mesoNowPlayingUUID
                                                            properties:CBCharacteristicPropertyRead
                                                                 value:nowplayingdata
                                                           permissions:CBAttributePermissionsReadable];
        
        deviceNameChar = [[CBMutableCharacteristic alloc] initWithType:mesoDeviceNameUUID properties:CBCharacteristicPropertyRead value:deviceNameData permissions:CBAttributePermissionsReadable];
        
        mesoUUIDChar = [[CBMutableCharacteristic alloc] initWithType:mesoUUIDUUID properties:CBCharacteristicPropertyRead value:mesoUUIDData permissions:CBAttributePermissionsReadable];
        
        mesoService = [[CBMutableService alloc] initWithType:mesoServiceUUID primary:YES];
        
        // Set characterisitc to service
        [mesoService setCharacteristics:@[nowPlayingChar, deviceNameChar, mesoUUIDChar]];
        
        // Publish Service
        [peripheralManager addService:mesoService];
        
        // Start advertising
        [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[mesoService.UUID], CBAdvertisementDataLocalNameKey : deviceName}];
    }
    
}

#pragma mark - LGBluetooth

-(void) processPeripherals:(LGPeripheral*) peripheral{
    // Open connection to peripheral
    [peripheral connectWithCompletion:^(NSError *error) {
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                
                // Find Meso Service
                if ([service.UUIDString isEqualToString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A".lowercaseString]) {
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        
                        __block NSString* peerUUID, *peerName, *peerSong;
                        __block int i = 0;
                        
                        for (LGCharacteristic* eachChar in characteristics){
                            // UUID
                            if ([eachChar.UUIDString isEqualToString:@"724E6C05-9820-4951-B3CA-DE2737538166".lowercaseString]){
                                
                                [eachChar readValueWithBlock:^(NSData *data, NSError *error) {
                                    // Make data
                                    NSString* value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    peerUUID = value;
                                    i++;
                                    if (i == 3) [self finishConnectionWithUUID:peerUUID Name:peerName Song:peerSong Peripheral:peripheral];
                                }];
                            }
                            // Name
                            else if ([eachChar.UUIDString isEqualToString:@"7404CEA2-B789-4533-8AE7-A551488C2C84".lowercaseString]){
                                
                                [eachChar readValueWithBlock:^(NSData *data, NSError *error) {
                                    // Make data
                                    NSString* value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    peerName = value;
                                    i++;
                                    if (i == 3) [self finishConnectionWithUUID:peerUUID Name:peerName Song:peerSong Peripheral:peripheral];
                                }];
                            }
                            // Now Playing Sharing String
                            else if ([eachChar.UUIDString isEqualToString:@"A4055D4E-CAEA-4BF3-8FDC-62EA5621D32B".lowercaseString]){
                                
                                [eachChar readValueWithBlock:^(NSData *data, NSError *error) {
                                    // Make data
                                    NSString* value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    peerSong = value;
                                    i++;
                                    if (i == 3) [self finishConnectionWithUUID:peerUUID Name:peerName Song:peerSong Peripheral:peripheral];
                                }];
                            }
                        }
                        
                    }];
                }
            }
        }];
    }];
}

- (void) finishConnectionWithUUID:(NSString*)uuid Name:(NSString*)name Song:(NSString*)song Peripheral:(LGPeripheral*) peripheral{
    
    NSDictionary* peer = [MSPMesoTableViewController makePeerItemFromName:name NowPlayingItem:song];
    [MSPSharingManager addDeviceWithUUID:[[NSUUID alloc] initWithUUIDString:uuid] PeerInfo:peer];
    [_deviceTable reloadData];
    
    [peripheral disconnectWithCompletion:nil];
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
    [[cell textLabel] setText:[peerInfo objectForKey:@"keydevicename"]];
    [[cell detailTextLabel] setText:[peerInfo objectForKey:@"keynowplaying"]];
    
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


#pragma mark - Bluetooth

- (IBAction)buttonRefresh:(id)sender {
    // Start scanning for peripherals
    // Process the peripherals found after 4 seconds
    NSLog(@"Scan Started");

    
    CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A"];
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:4 services:@[mesoServiceUUID] options:nil completion:^(NSArray *peripherals)
     {
         NSLog(@"Scan Stopped, %ld peripherals found", (long)peripherals.count);
         for (LGPeripheral* eachPeri in peripherals) {
             [self processPeripherals:eachPeri];
         }
     }];
}

#pragma mark - Helper functions

+ (NSDictionary*) makePeerItemFromName:(NSString*)name NowPlayingItem:(NSString*)nowPlaying{
    return @{@"keydevicename": name, @"keynowplaying":nowPlaying};
}

- (void) updateProfile{
    
    // Load Profile Info
    [_labelProfileName setText:[MSPSharingManager userProfileName]];
    [_labelPersonalMessage setText:[MSPSharingManager userProfileMessage]];
    UIImage* avatar = [MSPSharingManager userProfileAvatar];
    if (avatar){
        [_imageAvatar setImage:avatar];
    }
}

@end
