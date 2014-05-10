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
        UIImage* image = [MSPSharingManager userProfileAvatar];
        if (image){
            [_buttonAvatar setImage:image forState:UIControlStateNormal];
        }
    }
    
    // Set Done button depending on validation
    [_buttonDone setEnabled:[self validateInput]];
    
    // Select text field
    [_fieldDisplayName becomeFirstResponder];
    
    // Set correct content mode for avatar image
    [[_buttonAvatar imageView] setContentMode:UIViewContentModeScaleAspectFill];

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
    [MSPSharingManager setUserProfileAvatar:_buttonAvatar.imageView.image];

    [[(MSPProfileViewController*)self.parentViewController peopleViewController] updateProfile];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)nameFieldChanged:(id)sender {
    // Set Done button depending on validation
    [_buttonDone setEnabled:[self validateInput]];
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
    UIImage* resizedImage = [image thumbnailImage:200 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationDefault];
    [_buttonAvatar setImage:resizedImage forState:UIControlStateNormal];
}

@end
