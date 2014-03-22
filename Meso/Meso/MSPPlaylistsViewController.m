//
//  MSPPlaylistsViewController.m
//  Meso
//
//  Created by Gun on 22/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPPlaylistsViewController.h"

@interface MSPPlaylistsViewController ()

@end

@implementation MSPPlaylistsViewController

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
    // Do any additional setup after loading the view.
    
    // Initialize the playlist tree structure
    if (!_playlistTree) _playlistTree = [[MSPPlaylistNode alloc] initAsRoot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
