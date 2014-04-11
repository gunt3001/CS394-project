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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Do Initial Table Update
    [self refreshTable];
    
    // Setup further media updates
    [self setupMediaUpdate];
    
    // Scroll to now playing item
    NSIndexPath* nowPlayingItem = [NSIndexPath indexPathForRow:[[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem]
                                                     inSection:0];
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

#pragma mark - Table view data source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Queue
        case 0:
            return 1;
        
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
            // Songs in current Queue
            return [[MSPMediaPlayerHelper sharedPlayer] numberOfItems];
            
        // Album - show songs in the album
        case 1:
            return [MSPMediaPlayerHelper itemsInCurrentSongAlbum].items.count;
            
        default:
            return 0;
    }
}

- (MSPTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell* cell;
    
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitemcompact" forIndexPath:indexPath];
            
            // Get the corresponding media item
            MPMediaItem* item = [[MSPMediaPlayerHelper sharedPlayer] nowPlayingItemAtIndex:(unsigned int)[indexPath row]];
            // Set its info
            NSString* optionalString;
            // If it's the currently playing song, show play icon
            if ([indexPath row] == [[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem])
                optionalString = @"\U000025B6\U0000FE0E";
            else
                optionalString = [NSString stringWithFormat:@"%ld", (long)[indexPath row] + 1];
            [cell setSongInfo:item WithString:optionalString ShowAlbum:YES];
            break;
        }

        // Album
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitemcompactnoalbum" forIndexPath:indexPath];
            
            // Get the corresponding media item
            NSArray* itemsInAlbum = [MSPMediaPlayerHelper itemsInCurrentSongAlbum].items;
            MPMediaItem* item = itemsInAlbum[indexPath.row];
            NSUInteger trackNo = [[item valueForProperty:MPMediaItemPropertyAlbumTrackNumber] unsignedIntegerValue];
            
            // Set its info
            NSString* optionalString;
            // If it's the currently playing song, show play icon
            if (item == [[MSPMediaPlayerHelper sharedPlayer] nowPlayingItem])
                optionalString = @"\U000025B6\U0000FE0E";
            else
                optionalString = [NSString stringWithFormat:@"%lu", (unsigned long)trackNo];
            
            [cell setSongInfo:item WithString:optionalString ShowAlbum:NO];
            break;
        }
            
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
    switch ([_tableTabSegment selectedSegmentIndex]) {
        case 0:
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
                // Deselect
                [_tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;
            
        case 1:
        {
            // Start playing selected song with album as queue
            MPMediaQuery* itemsInAlbum = [MSPMediaPlayerHelper itemsInCurrentSongAlbum];
            MPMediaItem* item = itemsInAlbum.items[indexPath.row];
            [MSPMediaPlayerHelper playSong:item QueueQuery:itemsInAlbum];
            
            // Scroll to selected item
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            // Deselect
            [_tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([_tableTabSegment selectedSegmentIndex]) {
        case 0:
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
            return;
            
        case 1:
        default:
            return;
            
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // Show menu as header on up next tab
    if (_tableTabSegment.selectedSegmentIndex == 0){
        return [tableView dequeueReusableCellWithIdentifier:@"idminimenuitem"];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    switch (_tableTabSegment.selectedSegmentIndex){
        case 0:
            return 30;
        case 1:
            return 0;
        default:
            return 0;
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
    if (_parentPopover){
        // iPad Popover
        [_parentPopover dismissPopoverAnimated:YES];
    }
    else{
        // iPhone modal segue
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
        [selectedIndexes addObject:[NSNumber numberWithLong:[eachSelectedPath row]]];
    }
    
    [MSPMediaPlayerHelper setQueueWithSubsetIndexes:selectedIndexes];
    [self refreshTable];
    
    // Scroll to top
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (IBAction)tableTabSegmentChanged:(UISegmentedControl*)sender {
    // Update table data on tab segment change
    [self refreshTable];
    
    // Scroll back to now playing item
    if ([sender selectedSegmentIndex] == 0){
        NSIndexPath* nowPlayingItem = [NSIndexPath indexPathForRow:[[MSPMediaPlayerHelper sharedPlayer] indexOfNowPlayingItem]
                                                         inSection:0];
        [_tableView scrollToRowAtIndexPath:nowPlayingItem atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    // Reset Edit Mode
    editMode = NO;
    [_tableView setAllowsMultipleSelection:NO];
}
- (IBAction)shareButton:(id)sender {
    // Have user select what service to share to
    // Meso, Twitter, or FB
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share with Meso", @"Share to Twitter", @"Share to Facebook", nil];
    [actionSheet showInView:self.view.window];
    
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
