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

@interface MSPMesoTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelPersonalMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelProfileName;

@end

@implementation MSPMesoTableViewController{
    // Private variables
    NSMutableArray* discoveredDevices;
    CBPeripheralManager* peripheralManager;
    dispatch_queue_t peripheralQueue;
    
    // Peripheral Manager
    CBMutableService* mesoService;
    CBMutableCharacteristic* nowPlayingChar;
    CBMutableCharacteristic* deviceNameChar;
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
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"]){
        // TBD: Show Welcome page & Instructions
        
        [self performSegueWithIdentifier:@"segueProfileSetup" sender:self];
    }
    
    // Load Profile Info
    [self updateProfile];
    
    // Setup table
    discoveredDevices = [[NSMutableArray alloc] init];
    
    // Make sample data
    NSDictionary* peer = [MSPMesoTableViewController makePeerItemFromName:@"Device Name" NowPlayingItem:@"Some Song"];
    [discoveredDevices addObject:peer];
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
        
        // Create Characteristic
        MPMusicPlayerController* ipod = [MPMusicPlayerController iPodMusicPlayer];
        MPMediaItem* nowplaying = [ipod nowPlayingItem];
        NSString* nowplayingtitle = [nowplaying valueForProperty:MPMediaItemPropertyTitle];
        NSData* nowplayingdata = [nowplayingtitle dataUsingEncoding:NSUTF8StringEncoding];
        NSString* deviceName = [[UIDevice currentDevice] name];
        NSData* deviceNameData = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
        
        nowPlayingChar = [[CBMutableCharacteristic alloc] initWithType:mesoNowPlayingUUID
                                                            properties:CBCharacteristicPropertyRead
                                                                 value:nowplayingdata
                                                           permissions:CBAttributePermissionsReadable];
        
        deviceNameChar = [[CBMutableCharacteristic alloc] initWithType:mesoDeviceNameUUID properties:CBCharacteristicPropertyRead value:deviceNameData permissions:CBAttributePermissionsReadable];
        
        mesoService = [[CBMutableService alloc] initWithType:mesoServiceUUID primary:YES];
        
        // Set characterisitc to service
        [mesoService setCharacteristics:@[nowPlayingChar, deviceNameChar]];
        
        // Publish Service
        [peripheralManager addService:mesoService];
        
        // Start advertising
        [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[mesoService.UUID], CBAdvertisementDataLocalNameKey : deviceName}];
    }
    
}

#pragma mark - LGBluetooth

-(void) processPeripherals:(LGPeripheral*) peripheral{
    // First of all, opening connection
    [peripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            // Searching in all services
            for (LGService *service in services) {
                if ([service.UUIDString isEqualToString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A".lowercaseString]) {
                    // Discovering characteristics of 5ec0 service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        __block int i = 0;
                        // Searching readable characteristic - cef9
                        for (LGCharacteristic *charact in characteristics) {
                            if ([charact.UUIDString isEqualToString:@"A4055D4E-CAEA-4BF3-8FDC-62EA5621D32B".lowercaseString]) {
                                [charact readValueWithBlock:^(NSData *data, NSError *error) {
                                    NSLog(@"found our service!");
                                    // Make data
                                    NSString* nowPlayingValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    NSDictionary* peer = [MSPMesoTableViewController makePeerItemFromName:@"Unknown Device" NowPlayingItem:nowPlayingValue];
                                    [discoveredDevices addObject:peer];
                                    [_deviceTable reloadData];

                                    [peripheral disconnectWithCompletion:nil];
                                }];
                            }
                        }
                    }];
                }
            }
        }];
    }];
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
    return [discoveredDevices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idpeeritem" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary* peer = [discoveredDevices objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[peer objectForKey:@"keydevicename"]];
    [[cell detailTextLabel] setText:[peer objectForKey:@"keynowplaying"]];
    
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
    [_labelProfileName setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"]];
    [_labelPersonalMessage setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileMessage"]];
    NSString* imagePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileAvatar"];
    if (imagePath){
        [_imageAvatar setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]]];
    }
}

@end
