//
//  MSPPeerTableViewController.m
//  Meso
//
//  Created by Gun on 5/12/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPeerTableViewController.h"
#import "MSPSharingManager.h"

@interface MSPPeerTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelPeerMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelPeerMet;
@property (weak, nonatomic) IBOutlet UIImageView *imagePeerAvatar;

@end

@implementation MSPPeerTableViewController

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
    
    // Set user profile
    NSString* displayName = [_peerInfo objectForKey:@"name"];
    NSString* message = [_peerInfo objectForKey:@"message"];
    NSInteger avatarID = [(NSNumber*)[_peerInfo objectForKey:@"avatar"] integerValue];
    UIImage* avatar = [MSPSharingManager avatarWithID:avatarID];
    NSNumber* numMet = [_peerInfo objectForKey:@"nummet"];
    
    [self.navigationItem setTitle:displayName];
    [_labelPeerMessage setText:message];
    [_labelPeerMet setText:[NSString stringWithFormat:@"Met %@ People", numMet]];
    [_imagePeerAvatar setImage:avatar];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

@end
