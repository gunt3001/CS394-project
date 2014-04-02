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
#import "MPMusicPlayerController+PrivateInterface.h"
#import "MSPMediaPlayerHelper.h"

@interface MSPUpNextViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MSPUpNextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide Footer
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        
        // Up Next Mini Menu
        case 0:
            return @"Up Next";
        
        // Up Next list
        case 1:
            return nil;
            
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    
    switch (section) {
            
        // Menus have only 1 row
        case 0:
            return 1;
            break;
            
        // Up next
        case 1: {
            // As long as we still have upcoming songs, we show them
            // with a limit of: UPNEXT_COUNT
            NSInteger upcomingCount = [MSPMediaPlayerHelper itemsLeftInPlayingQueue];
            if (upcomingCount < UPNEXT_COUNT) return upcomingCount;
            else return UPNEXT_COUNT;
        }
            
        default:
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        
        // Mini menu has extra small row
        case 0:
            return 30;
            
        // Upnext items has the default row height
        case 1:
            return TABLE_VIEW_SONG_ROW_HEIGHT;
            
        default:
            // Fallback to default
            return TABLE_VIEW_SONG_ROW_HEIGHT;
    }
}

- (MSPTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell* cell;
    
    switch (indexPath.section) {
        // Mini Menu
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"idminimenuitem" forIndexPath:indexPath];
            break;
            
        // Song List
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
            // Get the upcoming media item
            MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemFromCurrentOffset:[indexPath row]];
            // Set its info
            [cell setSongInfo:next];
            break;
        }
            
        default:
            break;
    }
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    switch (indexPath.section) {
        case 0: // Mini Menu
            return NO;
        case 1: // Songs
            return YES;
        default:
            return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [MSPMediaPlayerHelper removeUpcomingItemAtOffset:indexPath.row];
        
        // Modify Table
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // If we still have an upcoming song, add it to table
        NSIndexPath* lastIndex = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:1] - 1) inSection:1];
        MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemFromCurrentOffset:[lastIndex row]];
        if (next){
            NSIndexPath* lastIndex = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:1] - 1) inSection:1];
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
    if (indexPath.section == 1) return YES;
    return NO;
}

// Limit rearrange to within its own section
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
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

#pragma mark - Button Actions

- (IBAction)doneButton:(id)sender {
    // Close upnext view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonShareMeso:(id)sender {
}

- (IBAction)buttonEdit:(UIButton*)sender {
    // Toggle the editing status
    
    if (_tableView.editing){
        [_tableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else{
        [_tableView setEditing:YES animated:YES];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
}

@end
