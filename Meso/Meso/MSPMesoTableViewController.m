//
//  MSPMesoTableViewController.m
//  Meso
//
//  Created by Gun on 23/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPMesoTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MSPMesoTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;

@end

@implementation MSPMesoTableViewController{
    // Private variables
    CBCentralManager* bluetoothManager;
    CBPeripheralManager* peripheralManager;
    NSMutableArray* discoveredDevices;
    NSMutableArray* connectedBluetoothPeripherals;
    dispatch_queue_t centerQueue;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set up central manager
    if (!bluetoothManager){
        centerQueue = dispatch_queue_create("centralqueue", NULL);
        bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:centerQueue];
        connectedBluetoothPeripherals = [[NSMutableArray alloc] init];
    }
    
    // Set up peripheral manager
    if (!peripheralManager){
        peripheralQueue = dispatch_queue_create("periqueue", NULL);
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralQueue];
    }
    
    // Set up data for table
    if (!discoveredDevices){
        discoveredDevices = [[NSMutableArray alloc] init];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSData* nowplayingdata = [nowplayingtitle dataUsingEncoding:NSUnicodeStringEncoding];
        NSString* deviceName = [[UIDevice currentDevice] name];
        NSData* deviceNameData = [deviceName dataUsingEncoding:NSUnicodeStringEncoding];
        
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

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request {
    
    NSLog(@"Received request from something");
    
    if ([request.characteristic.UUID isEqual:nowPlayingChar.UUID]) {
        if (request.offset > nowPlayingChar.value.length) {
            [peripheralManager respondToRequest:request
                                     withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [nowPlayingChar.value subdataWithRange:NSMakeRange(request.offset,
                                                                           nowPlayingChar.value.length - request.offset)];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else if ([request.characteristic.UUID isEqual:deviceNameChar.UUID]){
        if (request.offset > deviceNameChar.value.length){
            [peripheralManager respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [deviceNameChar.value subdataWithRange:NSMakeRange(request.offset,
                                                                           nowPlayingChar.value.length - request.offset)];
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}
- (void) peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error){
        NSLog(@"Error publishing service %@", [error localizedDescription]);
    }
}

#pragma mark - Bluetooth Central

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"central update state");
    
    if ([central state] == CBCentralManagerStatePoweredOn){
        CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A"];
        
        [bluetoothManager scanForPeripheralsWithServices:@[mesoServiceUUID] options:nil];
        NSLog(@"central scanning");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"central discovered %@", peripheral.name);
    [connectedBluetoothPeripherals addObject:peripheral];
    
    // Stop discovering devices
    [bluetoothManager stopScan];
    
    // Stop advertising too
    [peripheralManager stopAdvertising];
    
    // Connnect to it right away
    [bluetoothManager connectPeripheral:peripheral options:nil];
    
    
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"Connected to %@", peripheral.name);
    
    [peripheral setDelegate:self];
    
    // Discover its services
    CBUUID* mesoServiceUUID = [CBUUID UUIDWithString:@"D4D10CD7-6E88-4FBA-80E2-32D5B351B66A"];
    [peripheral discoverServices:@[mesoServiceUUID]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed to connect to %@ due to %@", peripheral.name, error.localizedDescription);
}

#pragma mark - Bluetooth Central - Connected Peripheral

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    
    // Discover the characteristics
    CBUUID* mesoNowPlayingUUID = [CBUUID UUIDWithString:@"A4055D4E-CAEA-4BF3-8FDC-62EA5621D32B"];
    CBUUID* mesoDeviceNameUUID = [CBUUID UUIDWithString:@"7404CEA2-B789-4533-8AE7-A551488C2C84"];
    
    [peripheral discoverCharacteristics:@[mesoNowPlayingUUID, mesoDeviceNameUUID] forService:[[peripheral services] objectAtIndex:0]];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    // Read the characteristic value found
    [peripheral readValueForCharacteristic:[[service characteristics] objectAtIndex:0]];
    [peripheral readValueForCharacteristic:[[service characteristics] objectAtIndex:1]];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
    // Finally get data from characteristic
    NSData* data = characteristic.value;
    
    // Parse data into string
    NSString* nowPlayingValue = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
    
    // Add data to table
    NSDictionary* peer = [MSPMesoTableViewController makePeerItemFromName:[peripheral name] NowPlayingItem:nowPlayingValue];
    [discoveredDevices addObject:peer];
    
    
    // Update table
    dispatch_async(dispatch_get_main_queue(), ^{
        [_deviceTable reloadData];
    });
    
    // Disconnect
    // [bluetoothManager cancelPeripheralConnection:peripheral];
    
    // Rediscover and readvertise
    NSString* deviceName = [[UIDevice currentDevice] name];
    [peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[mesoService.UUID], CBAdvertisementDataLocalNameKey : deviceName}];
    
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


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Buttons

- (IBAction)buttonRefresh:(id)sender {
    
}

#pragma mark - Helper functions

+ (NSDictionary*) makePeerItemFromName:(NSString*)name NowPlayingItem:(NSString*)nowPlaying{
    return @{@"keydevicename": name, @"keynowplaying":nowPlaying};
}

@end
