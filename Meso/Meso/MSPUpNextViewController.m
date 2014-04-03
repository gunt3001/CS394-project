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
#import "MSPMediaPlayerViewHelper.h"

@interface MSPUpNextViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageArtworkBack;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tableTabSegment;

@end

@implementation MSPUpNextViewController{
    MSPMediaPlayerViewHelper*    playerController;
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
                case 0:
                {
                    // As long as we still have upcoming songs, we show them
                    // with a limit of: UPNEXT_COUNT
                    NSInteger upcomingCount = [MSPMediaPlayerHelper itemsLeftInPlayingQueue];
                    if (upcomingCount < UPNEXT_COUNT) return upcomingCount;
                    else return UPNEXT_COUNT;
                }
                    
                // Upcoming Menu
                case 1:
                    return 1;
            }
        
        // Previous
        case 1:
            return 0;
#warning incomplete

        // Album - show songs in the album
        case 2:
            return 0;
#warning incomplete
            
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
                case 0:
                    return TABLE_VIEW_SONG_ROW_HEIGHT;
                    
                // Menu has extra small row
                case 1:
                    return 33;
            }
            
        // Previous
        case 1:
            return TABLE_VIEW_SONG_ROW_HEIGHT;
            
        // Album
        case 2:
            return TABLE_VIEW_SONG_ROW_HEIGHT;
            
        default:
            return TABLE_VIEW_SONG_ROW_HEIGHT;
    }
}

- (MSPTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPTableViewCell* cell;
    
    switch ([_tableTabSegment selectedSegmentIndex]) {
        // Upcoming
        case 0:
            switch (indexPath.section) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"idsongitem" forIndexPath:indexPath];
                    // Get the upcoming media item
                    MPMediaItem* next = [MSPMediaPlayerHelper nowPlayingItemFromCurrentOffset:[indexPath row]];
                    // Set its info
                    [cell setSongInfo:next];
                    break;
                }
                    
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"idminimenuitem" forIndexPath:indexPath];
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);    // Remove separator line
                    break;
                }
            }
            
        // Previous
        case 1:
            break;
            
        // Album
        case 2:
            break;
            
        default:
            break;
    }
    return cell;
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

- (IBAction)buttonLeaveOne:(id)sender {
}

- (IBAction)buttonClear:(id)sender {
}
- (IBAction)tableTabSegmentChanged:(id)sender {
    // Update table data on tab segment change
    
    [_tableView reloadData];
}

@end
