//
//  EditViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "EditViewController.h"
#import "SQLiteMananger.h"

@interface EditViewController () <QBActionStatusDelegate, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate>
- (IBAction) update:(id)sender;
//- (IBAction) back:(id)sender;
//- (IBAction) hideKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *userFoto;
@property UIImage *profilePicture;
@property (readonly, nonatomic) NSURL *imageUrl;
@property (nonatomic, weak) IBOutlet UITextField* loginFiled;
@property (nonatomic, weak) IBOutlet UITextField* fullNameField;
@property (nonatomic, weak) IBOutlet UITextField* phoneField;
@property (nonatomic, weak) IBOutlet UITextField* emailField;
@property (nonatomic, weak) IBOutlet UITextField* websiteField;
@property (nonatomic, weak) IBOutlet UITextField *tagsField;




@property (weak,nonatomic) UITextField* activeField;
@end

@implementation EditViewController


- (void) viewDidLoad {
//     NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
//    NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
//    UIImage *image = [UIImage imageWithContentsOfFile:[imageUrl path]];
   // [self.view addSubView: _userFoto];
    //[_userFoto setImage:_image];
    
    
//    NSUInteger userProfilePictureID = _user.blobID;
//    [QBContent TDownloadFileWithBlobID:userProfilePictureID delegate:self];
    [self onDownloadAvatarImage];
    
    CGSize s = scrollview.frame.size;
    s.height += 250;
    [scrollview setContentSize:s];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    self.tagsField = nil;
    self.fullNameField = nil;
    self.phoneField = nil;
    self.emailField = nil;
    self.websiteField = nil;
    self.tagsField = nil;
    
   
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.loginFiled.text    = [LocalStorageService shared].currentUser.login;
    self.fullNameField.text = [LocalStorageService shared].currentUser.fullName;
    self.phoneField.text    = [LocalStorageService shared].currentUser.phone;
    self.emailField.text    = [LocalStorageService shared].currentUser.email;
    self.websiteField.text  = [LocalStorageService shared].currentUser.website;
    
    for (NSString *tag in self.user.tags) {
        if([self.tagsField.text length] == 0) {
            self.tagsField.text = tag;
        } else {
            self.tagsField.text = [NSString stringWithFormat:@"%@, %@", self.tagsField.text, tag];
        }
    }
    
    
 //   [self registerForKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.loginFiled resignFirstResponder];
    [self.fullNameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.websiteField resignFirstResponder];
}

- (IBAction)photoButtonTapped:(id)sender
{
    // Preset an action sheet which enables the user to take a new picture or select and existing one.
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    
    // Show the action sheet
    [sheet showFromToolbar:self.navigationController.toolbar];
}
#pragma mark - UIActionSheetDelegate methods

// Override this method to know if user wants to take a new photo or select from the photo library
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if (imagePicker) {
        // set the delegate and source type, and present the image picker
        imagePicker.delegate = self;
        if (0 == buttonIndex) {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (1 == buttonIndex) {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else {
        // Problem with camera, alert user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Please use a camera enabled device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UIImagePickerViewControllerDelegate

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// Override this delegate method to get the image that the user has selected and send it view Multipeer Connectivity to the connected peers.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Don't block the UI when writing the image to documents
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // We only handle a still image
        UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self uploadAvatarImage:imageToSave];
//        // Save the new image to the documents directory
//        NSData *pngData = UIImageJPEGRepresentation(imageToSave, 0.0);
//        
//        // Create a unique file name
//        NSDateFormatter *inFormat = [NSDateFormatter new];
//        [inFormat setDateFormat:@"yyMMdd-HHmmss"];
//        NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
//        // Create a file path to our documents directory
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
//        [pngData writeToFile:filePath atomically:YES]; // Write the file
//        // Get a URL for this file resource
//        NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
//        
//        UIImage *image = [UIImage imageWithContentsOfFile:[imageUrl path]];
//        NSData *imageData = UIImageJPEGRepresentation(image, 0.0);
//        self.userFoto.image = image;
//       // _userFoto setImage:[image]
//        [QBContent TUploadFile:imageData fileName:(imageName) contentType:@"image/jpg" isPublic:NO delegate:self];
        
    });
}

#pragma mark -
#pragma mark QBActionStatusDelegate


// Update user
- (void)update:(id)sender {
    
    QBUUser * user  =[QBUUser user];
    user.ID = [LocalStorageService shared].currentUser.ID;
    
    if ([self.loginFiled.text length] != 0) {
        [LocalStorageService shared].currentUser.login = self.loginFiled.text;
        user.login = self.loginFiled.text;
    }
    
    if ([self.fullNameField.text length] != 0) {
        [LocalStorageService shared].currentUser.fullName = self.fullNameField.text;
        user.fullName = self.fullNameField.text;
    }
    
    if ([self.phoneField.text length] != 0) {
        [LocalStorageService shared].currentUser.phone = self.phoneField.text;
        user.phone = self.phoneField.text;
    }
    
    if ([self.emailField.text length] != 0) {
        [LocalStorageService shared].currentUser.email = self.emailField.text;
        user.email = self.emailField.text;
    }
    
    if ([self.websiteField.text length] != 0) {
        [LocalStorageService shared].currentUser.website = self.websiteField.text;
        user.website = self.websiteField.text;
    }
    
    if  ([self.tagsField.text length] != 0) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[self.tagsField.text stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
        [LocalStorageService shared].currentUser.tags = array;
        user.tags = array;
    }
    // update user
    
    [QBUsers updateUser: user delegate:self];
    [[SQLiteMananger SharedDataBase] insertProfileinfo:user];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  //  QBCFileUploadTaskResult *res = (QBCFileUploadTaskResult *)result;
            //  NSUInteger uploadedFileID = res.uploadedBlob.ID;
             // Connect image to user
              //  QBUUser *user = [QBUUser user];
            //    user.ID = [LocalStorageService shared].currentUser.ID;
              //  user.blobID = uploadedFileID;
              //  [QBUsers updateUser:user delegate:self];
                
    // Edit user result
    if ([result isKindOfClass:[QBUUserResult class]]) {
        // Success result
        if (result.success) { 
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:@"Profil wurde aktualliesiert"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil, nil];
            [alert show];
                       
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Fehler" object:nil userInfo:@{@"user" : self.user}];
        
        // Errors
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:[result.errors description]
                                                    delegate:nil 
                                                    cancelButtonTitle:@"Okay" 
                                                    otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if (result.success) {
        if ([result isKindOfClass:[QBCFileUploadTaskResult class]]) {

            QBCFileUploadTaskResult * res = (QBCFileUploadTaskResult *) result;
            NSUInteger  uploadFileID = res.uploadedBlob.ID;
            
            QBUUser  * user = [QBUUser user];
            user.ID = [LocalStorageService shared].currentUser.ID;
            user.blobID = uploadFileID;
            
            [QBUsers updateUser:user delegate:self];
        }
        else if ([result isKindOfClass:[QBCFileDownloadTaskResult class]]) {
            
            QBCFileDownloadTaskResult * res = (QBCFileDownloadTaskResult *) result;
            UIImage * img = [UIImage imageWithData:res.file];
            [self setAvatarImage:img];
            
        }
        
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


#pragma  mark - avatar image upload and download


- (void) uploadAvatarImage :(UIImage *) img {
    
    NSData * imgData = [[NSData alloc] initWithData:UIImagePNGRepresentation(img)];
    
    [QBContent TUploadFile:imgData fileName:@"profileIcon" contentType:@"image/png" isPublic:NO delegate:self];
    
}


- (void) onDownloadAvatarImage {

    NSUInteger userProfilePictureID = [LocalStorageService shared].currentUser.blobID;
    
    [QBContent TDownloadFileWithBlobID:userProfilePictureID delegate:self];
    
}

- (void) setAvatarImage : (UIImage *) img {
    
    [btnAvatar setImage:img forState:UIControlStateNormal];
    btnAvatar.layer.cornerRadius = 55;
    btnAvatar.layer.masksToBounds = YES;
    btnAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    btnAvatar.layer.borderWidth = 3.0f;
    btnAvatar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    btnAvatar.layer.shouldRasterize = YES;
    btnAvatar.clipsToBounds = YES;
    
}

@end
