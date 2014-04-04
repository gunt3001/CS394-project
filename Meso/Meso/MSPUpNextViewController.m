//
//  MSPUpNextViewController.m
//  Meso
//
//  Created by Gun on 4/1/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPUpNextViewController.h"
#import "MSPTableViewCell.h"
#import "MSPConstants.h"
#import "MSPMediaPlayerHelper.h"
#import "MSPNowPlayingViewController.h"

@interface MSPUpNextViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tableTabSegment;

@end

@implementation MSPUpNextViewController{
    BOOL                         editMode;
}

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
    
    editMode = NO;
    
    // Hide Footer
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    // Use toolbar trick to blur background
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setFrame:[self view].frame];
    [self.view insertSubview:toolBar atIndex:0];
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
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
            return 2;
        
        // Previous and Album
        case 1:
        case 2:
            return 1;
            
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
            switch (section) {
                // Upcoming Songs
                case 1:
                {
                    // As long as we still have upcoming songs, we show them
                    // with a limit of: UPNEXT_COUNT
                    NSInteger upcomingCount = [MSPMediaPlayerHelper itemsLeftInPlayingQueue];
                    return upcomingCount;
                }
                    
                // Upcoming Menu
                case 0:
                    return 1;
            }
        // Album - show songs in the album
        case 1:
            return 0;
            
        default:
            return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
            switch (indexPath.section) {
                // Upnext items has the default row height
                case 1:
                    return TABLE_VIEW_COMPACT_SONG_ROW_HEIGHT;
                    
                // Menu has extra small row
                case 0:
                    return 33;
            }
            
        // Album
        case 1:
            return TABLE_VIEW_COMPACT_SONG_ROW_HEIGHT;
            
        default:
            return TABLE_VIEW_COMPACT_SONG_ROW_HEIGHT;
    }
}

- (MSPTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell* cell;
    
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
            switch (indexPath.section) {
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitemcompact" forIndexPath:indexPath];
                    // Get the upcoming media item
                    MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemAfterCurrentWithOffset:[indexPath row]];
                    // Set its info
                    NSInteger numInQueue = [[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem] + [indexPath row] + 2;
                    [cell setSongInfo:next WithString:[NSString stringWithFormat:@"%d", numInQueue]];
                    break;
                }
                    
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"idminimenuitem" forIndexPath:indexPath];
                    break;
                }
            }
            break;

        // Album
        case 1:
            break;
            
        default:
            break;
    }
    
    if (editMode && [[tableView indexPathsForSelectedRows] containsObject:indexPath]){
        // Re-apply checkmark accessory on selected items
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Can't select the menu cell
    if (indexPath.section == 0){
        [_tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if (editMode){
        // Add Checkmark
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // Enable Queue button
        UIButton* buttonQueue = (UIButton*)[_tableView viewWithTag:102];
        [buttonQueue setEnabled:YES];
    }
    else{
        // If not in edit mode, start playing selected song
        [MSPMediaPlayerHelper playItemAfterCurrentWithOffset:[indexPath row]];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editMode){
        // Remove Checkmark
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // If there's no more selected, disable the queue button
        if (![_tableView indexPathsForSelectedRows]){
            UIButton* buttonQueue = (UIButton*)[_tableView viewWithTag:102];
            [buttonQueue setEnabled:NO];
            
        }
    }
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
    [(MSPNowPlayingViewController*)self.parentViewController hideMenu];
}

- (IBAction)editButton:(UIButton*)sender {
    // Enable queue editing
    
    if (editMode){
        editMode = NO;
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        sender.titleLabel.font = [UIFont systemFontOfSize:sender.titleLabel.font.pointSize];
        [_tableView setAllowsMultipleSelection:NO];
        [_tableView reloadData];
        
        // Disable queue button
        UIButton* buttonQueue = (UIButton*)[_tableView viewWithTag:102];
        [buttonQueue setEnabled:NO];
    }
    else{
        editMode = YES;
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        sender.titleLabel.font = [UIFont boldSystemFontOfSize:sender.titleLabel.font.pointSize];
        
        // Deselect any previously selected rows
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
        [_tableView setAllowsMultipleSelection:YES];
    }
}


- (IBAction)tableTabSegmentChanged:(id)sender {
    // Update table data on tab segment change
    
    [_tableView reloadData];
}

@end
