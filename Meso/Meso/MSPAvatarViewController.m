//
//  MSPAvatarViewController.m
//  Meso
//
//  Created by Gun on 5/12/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPAvatarViewController.h"
#import "MSPSharingManager.h"

@interface MSPAvatarViewController ()

@end

@implementation MSPAvatarViewController

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

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    // Hardcoded to 5 avatars for now
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{

    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"idavatar" forIndexPath:indexPath];
        
    // load the image for this cell
    UIImage* image = [MSPSharingManager avatarWithID:(indexPath.row + 1)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [cell setBackgroundView:imageView];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // Set Avatar
    [MSPSharingManager setUserProfileAvatar:(indexPath.row) + 1];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
