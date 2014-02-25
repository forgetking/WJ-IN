//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate, QBChatDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSString * chatStatusStr;
    BOOL        isChatStatus;
}

@property (weak, nonatomic) IBOutlet UIToolbar *messagesBar;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;

- (IBAction)sendMessage:(id)sender;
- (IBAction)sendFile:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
  //  [QBCustomObjects objectsWithClassName:@"Message" delegate:self];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    chatStatusStr = @"";
    isChatStatus = NO;
    
    if(self.opponent != nil){
        //[QBCustomObjects objectsWithClassName:@"Message" delegate:self];
        self.messages = [[LocalStorageService shared] messageHistoryWithUserID:self.opponent.ID];
       // self.messages = [[QBCustomObjects
    }else{
        self.messages = [NSMutableArray array];
    }
    
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)completedWithResult:(Result *)result{
    
    if(result.success && [result isKindOfClass:QBCOCustomObjectResult.class]){
        QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
        NSLog(@"QBCOCustomObjectResult, object=%@", res.object);
    }
    
    if (result.success) {
        if ([result isKindOfClass:[QBCFileUploadTaskResult class]]) {
            QBCFileUploadTaskResult * res = (QBCFileUploadTaskResult *)result;
            NSUInteger uploadFileID = res.uploadedBlob.ID;
            [self sendMessageWithUploadedFileId:uploadFileID];
        }
    }
    
    if (result.success) {
        if ([result isKindOfClass:[QBCFileDownloadTaskResult  class]]) {
            QBCFileDownloadTaskResult * res = (QBCFileDownloadTaskResult *) result;
            UIImage * image = [UIImage imageWithData:res.file];
            
            [self priviewAndSaveContent : image];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    // Set title
    if(self.opponent != nil){
        self.title = self.opponent.fullName;
    }else if(self.chatRoom != nil){
        self.title = self.chatRoom.name;
    }
    
    
    // Join room
    if(self.chatRoom != nil && ![self.chatRoom isJoined]){
        [[ChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
            // add the Admin to room
            [joinedChatRoom addUsers:@[@291]];
        }];
    }
    
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.chatRoom leaveRoom];
    
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // 1-1 Chat
    if(self.opponent != nil){
        // send message
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.recipientID = self.opponent.ID;
        message.text = self.messageTextField.text;
        
        [message saveWhenDeliveredToCustomObjectsWithClassName:@"Message" additionalParameters:nil];
        // save message to history
        [[ChatService instance] sendMessage:message];
        [[LocalStorageService shared] saveMessageToHistory:message withUserID:message.recipientID];
        
        [self.messages addObject:message];
        
    // Group Chat
    }else if(self.chatRoom != nil){
        
//        // Replace the next line with these lines if you would like to connect to Web XMPP Chat widget
//        //
//        NSDictionary *messageAsDictionary = @{@"message": self.messageTextField.text};
//        NSData *messageAsData = [NSJSONSerialization dataWithJSONObject:messageAsDictionary options:0 error:nil];
//        NSString *message =[[NSString alloc] initWithData:messageAsData encoding:NSUTF8StringEncoding];
//        NSString *escapedMessage = [CharactersEscapeService escape:message];
//        //
//        [[ChatService instance] sendMessage:escapedMessage toRoom:self.chatRoom];
        
        [[ChatService instance] sendMessage:self.messageTextField.text toRoom:self.chatRoom];
        
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
    
}

- (IBAction)sendFile:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if (imagePicker) {

        imagePicker.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
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

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *imageToSend = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self  uploadFile : imageToSend];
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomName = notification.userInfo[kRoomName];
    
    if([self.chatRoom.JID rangeOfString:roomName].length <=0 ){
        return;
    }
    
    [self.messages addObject:message];
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isChatStatus == YES) {
        return [self.messages count] + 1;
    }
	return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    if ((isChatStatus == YES) && ([self.messages count] == indexPath.row)) {
        cell.textLabel.text = [NSString stringWithFormat:@"%lu is typing....", self.opponent.ID];
    } else {
        QBChatMessage *Message = (QBChatMessage *)self.messages[indexPath.row];
        [QBCustomObjects objectsWithClassName:@"Message" delegate:self];
        [cell configureCellWithMessage:Message is1To1Chat:self.opponent != nil];
    }
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatMessage *chatMessage = (QBChatMessage *)[self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage is1To1Chat:self.opponent != nil];
    return cellHeight;
}

#pragma mark
#pragma mark Keyboard notifications

#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    
    [UIView animateWithDuration:0.2 animations:^{
		self.messagesBar.transform = CGAffineTransformMakeTranslation(0, -215);
        self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -215);
        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -215);
        self.messagesTableView.transform = CGAffineTransformMakeTranslation(0, -215);
        self.messagesTableView.contentInset = UIEdgeInsetsMake(210, 0, 0, 0);
        // self.messagesTableView.contentOffset = CGPointMake(0, -215);
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)note
{
    
    [UIView animateWithDuration:0.2 animations:^{
		self.messageTextField.transform = CGAffineTransformIdentity;
        self.sendMessageButton.transform = CGAffineTransformIdentity;
        self.messagesBar.transform = CGAffineTransformIdentity;
        self.messagesTableView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    QBChatMessage   * message = [QBChatMessage message];
    message.recipientID = self.opponent.ID;
    [message setText:@"composing"];
    [message setCustomParameters:@{@"isComposing": @YES}];
    [[QBChat instance] sendMessage:message];
    
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    QBChatMessage   * message = [QBChatMessage message];
    message.recipientID = self.opponent.ID;
    [message setText:@"composing"];
    [message setCustomParameters:@{@"isComposing": @NO}];
    [[QBChat instance] sendMessage:message];
    
}

#pragma mark
#pragma mark QBChatDelegate

- (void) chatDidReceiveMessage:(QBChatMessage *)message {
    NSDictionary * customParameres = message.customObjectsAdditionalParameters;
    NSNumber * isComposingNotification = customParameres[@"isComposing"];
    
    if (isComposingNotification != nil) {
        BOOL isComposingState = [isComposingNotification boolValue];
        if (isComposingState) {
            isChatStatus = YES;
        }
        else  {
            isChatStatus = NO;
        }
    }
    
    NSUInteger fileID = [message.customParameters[@"fileID"]  integerValue];
    [QBContent TDownloadFileWithBlobID:fileID delegate:self];
}

- (void) uploadFile : (UIImage *) img {
    
    NSData * imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];
    [QBContent TUploadFile:imageData fileName:@"Attached" contentType:@"image/png" isPublic:YES delegate:self];
}

- (void) sendMessageWithUploadedFileId : (NSUInteger)  blobID {
    QBChatMessage   * message = [QBChatMessage message];
    message.recipientID = self.opponent.ID;
    [message setCustomParameters:@{@"fileID": @(blobID)}];
    
    [[QBChat instance] sendMessage:message];
}

- (void) priviewAndSaveContent : (UIImage * ) image {
    
}

@end
