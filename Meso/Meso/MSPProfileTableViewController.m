//
//  MSPProfileTableViewController.m
//  Meso
//
//  Created by Gun on 5/9/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPProfileTableViewController.h"
#import "UIImage+Resize.h"
#import "MSPProfileViewController.h"
#import "MSPSharingManager.h"

@interface MSPProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelSharedCount;
@property (weak, nonatomic) IBOutlet UITextField *fieldDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *fieldPersonalMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonAvatar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
@end

@implementation MSPProfileTableViewController

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
    
    // Load existing profile if there is one
    if ([MSPSharingManager profileIsSet]){
        [_fieldDisplayName setText:[MSPSharingManager userProfileName]];
        [_fieldPersonalMessage setText:[MSPSharingManager userProfileMessage]];
    }
    
    // Set Done button depending on validation
    [_buttonDone setEnabled:[self validateInput]];
    
    // Set correct content mode for avatar image
    [[_buttonAvatar imageView] setContentMode:UIViewContentModeScaleAspectFill];

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Display number of shared songs
    if ([MSPSharingManager profileIsSet]){
        [_labelSharedCount setText:[NSString stringWithFormat:@"Sharing %ld songs", (long)[MSPSharingManager userProfileMesoList].count]];
    }
    
    UIImage* image = [MSPSharingManager avatarWithID:[MSPSharingManager userProfileAvatarID]];
    if (image){
        [_buttonAvatar setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - Buttons

- (IBAction)buttonAvatar:(id)sender {
    
    // Browse for avatar image
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)buttonDone:(id)sender {
    
    // Save profile
    [MSPSharingManager setUserProfileName:_fieldDisplayName.text];
    [MSPSharingManager setUserProfileMessage:_fieldPersonalMessage.text];

    [[(MSPProfileViewController*)self.parentViewController peopleViewController] updateProfile];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)nameFieldChanged:(id)sender {
    // Set Done button depending on validation
    [_buttonDone setEnabled:[self validateInput]];
}

- (IBAction)buttonClearHistory:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This will delete everyone you met!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles:nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - Helpers
- (BOOL)validateInput{
    // Validate the profile form
    // Everything but the name is optional
    if ([[_fieldDisplayName text] isEqualToString:@""]) return NO;
    return YES;
}

#pragma mark - Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // Takes care of return button on keyboard
    
    if (textField == _fieldDisplayName){
        // On name, move on to next field
        [_fieldPersonalMessage becomeFirstResponder];
    }
    else if (textField == _fieldPersonalMessage){
        // On personal message, dismiss keyboard
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Resize before setting
    UIImage* resizedImage = [image thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
    [_buttonAvatar setImage:resizedImage forState:UIControlStateNormal];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [MSPSharingManager clearDatabase];
        [[[(MSPProfileViewController*)self.parentViewController peopleViewController] tableView] reloadData];
    }
}

@end
