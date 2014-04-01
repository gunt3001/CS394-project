//
//  MSPUpNextViewController.m
//  Meso
//
//  Created by Gun on 4/1/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPUpNextViewController.h"
#import "MSPAppDelegate.h"
#import "MSPTableViewCell.h"
#import "MSPConstants.h"
#import "MPMusicPlayerController+CurrentQueue.h"
#import "MSPMediaPlayerHelper.h"

@interface MSPUpNextViewController ()

@end

@implementation MSPUpNextViewController

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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // As long as we still have upcoming songs, we show them
    // with a limit of: UPNEXT_COUNT
    NSInteger upcomingCount = [MSPMediaPlayerHelper itemsLeftInPlayingQueue];
    if (upcomingCount < UPNEXT_COUNT) return upcomingCount;
    else return UPNEXT_COUNT;
    
    return upcomingCount;
}


- (MSPTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
    
    // Get the upcoming media item
    MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemFromCurrentOffset:[indexPath row]];
    // Set its info
    [cell setSongInfo:next];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        // Modify Table
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // If we still have an upcoming song, add it to table
        NSIndexPath* lastIndex = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0];
        MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemFromCurrentOffset:[lastIndex row]];
        if (next){
            NSIndexPath* lastIndex = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0];
            [tableView insertRowsAtIndexPaths:@[lastIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView endUpdates];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButton:(id)sender {
    // Close upnext view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
