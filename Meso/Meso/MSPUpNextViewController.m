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
#import "MPMusicPlayerController+PrivateInterface.h"
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Setup media updates
    [self setupMediaUpdate];
    
    // Scroll to now playing item
    NSIndexPath* nowPlayingItem = [NSIndexPath indexPathForRow:[[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem]
                                                     inSection:1];
    [_tableView scrollToRowAtIndexPath:nowPlayingItem atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // Unset media updates
    [self unsetMediaUpdate];
}

#pragma mark Related Methods

- (void)setupMediaUpdate{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // Add observers
    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:[MSPMediaPlayerHelper sharedPlayer]];
}

- (void)unsetMediaUpdate{
    
    // Remove observers
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:[MSPMediaPlayerHelper sharedPlayer]];
   
}

- (void)handleNowPlayingItemChanged:(id)notification {
    // When the playing item changed, update the table
    [self refreshTable];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Queue
        case 0:
            return 2;
        
        // Album
        case 1:
            return 1;
            
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Queue
        case 0:
            switch (section) {
                // Songs in current Queue
                case 1:
                    return [[MSPMediaPlayerHelper sharedPlayer] numberOfItems];
                    
                // Mini Menu
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
                // Queue items has the default row height
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
                    
                    // Get the corresponding media item
                    MPMediaItem* item = [[MSPMediaPlayerHelper sharedPlayer] nowPlayingItemAtIndex:[indexPath row]];
                    // Set its info
                    NSString* optionalString;
                    // If it's the currently playing song, show play icon
                    if ([indexPath row] == [[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem])
                        optionalString = @"\U000025B6\U0000FE0E";
                    else
                        optionalString = [NSString stringWithFormat:@"%d", [indexPath row] + 1];
                    [cell setSongInfo:item WithString:optionalString];
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
        [MSPMediaPlayerHelper playItemAtIndex:[indexPath row]];
        [self refreshTable];

        // Scroll to selected item
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        [self refreshTable];
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

- (IBAction)buttonQueueSelected:(UIButton*)sender {
    NSMutableArray* selectedIndexes = [[NSMutableArray alloc] init];
    for (NSIndexPath* eachSelectedPath in [_tableView indexPathsForSelectedRows]) {
        [selectedIndexes addObject:[NSNumber numberWithInt:[eachSelectedPath row]]];
    }
    
    [MSPMediaPlayerHelper setQueueWithSubsetIndexes:selectedIndexes];
    [self refreshTable];
    
    // Scroll to top
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (IBAction)tableTabSegmentChanged:(UISegmentedControl*)sender {
    // Update table data on tab segment change
    [_tableView reloadData];
    
    // Show/hide header
    if ([sender selectedSegmentIndex] == 0){
        
    }
    else{
        
    }
}

#pragma mark - Other helper methods
- (void) refreshTable{
    // Reload data
    [_tableView reloadData];
    
    // Refresh buttton states
    // If there's no more selected, disable the queue button
    if (![_tableView indexPathsForSelectedRows]){
        UIButton* buttonQueue = (UIButton*)[_tableView viewWithTag:102];
        [buttonQueue setEnabled:NO];
        
    }
}

@end
