//
//  MSPProfileTableViewController.m
//  Meso
//
//  Created by Gun on 5/9/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPProfileTableViewController.h"

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
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"]){
        [_fieldDisplayName setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileName"]];
        [_fieldPersonalMessage setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileMessage"]];
        NSString* imagePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"MesoProfileAvatar"];
        if (imagePath){
            [_buttonAvatar setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]] forState:UIControlStateNormal];
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
    
    // Save settings
    [[NSUserDefaults standardUserDefaults] setObject:_fieldDisplayName.text forKey:@"MesoProfileName"];
    [[NSUserDefaults standardUserDefaults] setObject:_fieldPersonalMessage.text forKey:@"MesoProfileMessage"];
    
    // Get image data.
    NSData *imageData = UIImageJPEGRepresentation(_buttonAvatar.imageView.image, 1);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:@"avatar.jpg"];
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    // Store path in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"MesoProfileAvatar"];

    [[NSUserDefaults standardUserDefaults] synchronize];

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

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
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
    [_buttonAvatar setImage:image forState:UIControlStateNormal];
}

@end
