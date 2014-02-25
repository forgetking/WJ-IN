//
//  FirstViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "UsersPaginator.h"
#import "СhatViewController.h"
#import "LocalStorageService.h"
#import "UsersViewController.h"
#import "CustomizeUserCell.h"


@interface UsersViewController () <UITableViewDataSource, NMPaginatorDelegate, QBActionStatusDelegate, QBChatDelegate> {
    
    NSMutableDictionary * dicUsers;
    NSMutableDictionary * dicStatus;
    
}

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, weak) IBOutlet UITableView *usersTableView;
@property (nonatomic, strong) UsersPaginator *paginator;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property NSDictionary *imageForLabel;

@end

@implementation UsersViewController


#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin)
                                                 name:kUserLoggedInNotification object:nil];
    
    self.users = [NSMutableArray array];
    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
    
    dicUsers = [[NSMutableDictionary alloc] init];
    dicStatus = [[NSMutableDictionary alloc] init];
    
    [self userDidLogin];
    
    [self getContactList];
}


- (void)userDidLogin{
    
    [self setupTableViewFooter];
    
    // Fetch 10 users
    [self.paginator fetchFirstPage];
    
}

#pragma mark
#pragma mark Storyboard

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    // check if users is logged in
    if([LocalStorageService shared].currentUser == nil){
        //[((MainTabBarController *)self.tabBarController)
        self.view.hidden = NO;
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
    QBUUser *user = (QBUUser *)self.users[((UITableViewCell *)sender).tag];
    destinationViewController.opponent = user;
}


#pragma mark
#pragma mark Paginator

- (void)fetchNextPage
{
    [self.paginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.usersTableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
//    if ([self.paginator.results count] != 0){
//        self.footerLabel.text = [NSString stringWithFormat:@"%lu Gefundene Benutzer von %ld",
//                                 (unsigned long)[self.paginator.results count], (long)self.paginator.total];
//    }else{
//        self.footerLabel.text = @"";
//    }
    
    if ([self.users count] != 0){
        self.footerLabel.text = [NSString stringWithFormat:@"%lu Gefundene Benutzer von %ld",
                                 (unsigned long)[self.users count], (long)self.paginator.total];
    }else{
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return [self.users count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentify = @"UserCellIdentifier";
    CustomizeUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];

    if (cell == nil) {
        cell = [[CustomizeUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    cell.imageView.layer.cornerRadius = 25;
    cell.imageView.layer.masksToBounds = YES;
    
    QBUUser *user = (QBUUser *)self.users[indexPath.row];
    
    NSMutableArray * tmpArray = [[NSMutableArray alloc] init];
    NSString * forkey = [NSString stringWithFormat:@"%lu", user.blobID];
    tmpArray = [dicUsers objectForKey:forkey];
    [cell.imageView setFrame:CGRectMake(5, 3, 44, 44)];
    cell.tag = indexPath.row;
    
    if (user.blobID > 0) {
        if ([tmpArray count] > 0) {
            user = [tmpArray objectAtIndex:0];
            cell.textLabel.text = user.fullName;
        
            if ([tmpArray count] > 1) {
                [cell.imageView setImage:[tmpArray objectAtIndex:1]];
            }
            else {
                [self getAvatarIcon:user];
            }
        }
    }
    else {
        cell.textLabel.text = user.fullName;
    }
    
    // for online or offline
    NSString * forKey = [NSString stringWithFormat:@"%lu", user.ID];
    NSNumber * num = [dicStatus objectForKey:forKey];
    if ([num boolValue]) {
        
    } else {
        
    }
    
    [self checkUserStatus:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self performsegueView];
    
}

- (void) performsegueView {
//    [self performSegueWithIdentifier:@"showchatviewcontroller" sender:nil];
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height){
        // ask next page only if we haven't reached last page
        if(![self.paginator reachedLastPage]){
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}


#pragma mark
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // update tableview footer
 
    [self.activityIndicator stopAnimating];

    // reload table with users
    [self.users addObjectsFromArray:results];
    
    [self removeCurrentUserFromList];
    
    [self.usersTableView reloadData];
    
    [self updateTableViewFooter];
    
}

- (void) removeCurrentUserFromList {
    
    QBUUser * user = [LocalStorageService shared].currentUser;
   
    if (user) {
         NSMutableArray * tmpArray = [self.users mutableCopy];
        for (QBUUser * other in self.users) {
            if (other.ID == user.ID) {
                [tmpArray removeObject:other];
            } else {
                NSMutableArray * tmpArray = [[NSMutableArray alloc] init];
                [tmpArray addObject:other];
                NSString * forKey = [NSString stringWithFormat:@"%lu", other.blobID];
                [dicUsers setObject:tmpArray forKey:forKey];
                
                [self checkUserStatus: other];   // geting status of user
            }
        }
        self.users = [tmpArray mutableCopy];
    }
    
}

- (IBAction)onClickMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void) getAvatarIcon : (QBUUser *) user {
    
    NSUInteger userProfilePictureID = user.blobID;
    [QBContent TDownloadFileWithBlobID:userProfilePictureID delegate:self];
//    NSMutableArray * tmpArray = [[NSMutableArray alloc] init];
//    
//    [tmpArray addObject:user];
//    NSString * forKey = [NSString stringWithFormat:@"%lu", userProfilePictureID];
//    [usersDic setObject:tmpArray forKey:forKey];
    
}

- (void) completedWithResult:(Result *)result {
    
    if (result.success) {
        if ([result isKindOfClass:[QBCFileDownloadTaskResult class]]) {
            
            QBCFileDownloadTaskResult * res = (QBCFileDownloadTaskResult *) result;
            UIImage *img = [UIImage imageWithData:res.file];
            QBCBlob * blob = res.blob;
            NSUInteger blobID = blob.ID;
            
            [self setImageForUserIcon:blobID :[self resizeImag:img]];
        }
    }
}

- (void) setImageForUserIcon:(NSUInteger ) blobID : (UIImage *) img {
    
    NSMutableArray * tmpArray = [[NSMutableArray alloc] init];
    NSString * forKey = [NSString stringWithFormat:@"%lu", blobID];
    tmpArray = [dicUsers objectForKey:forKey];
    if (tmpArray == nil) {
        tmpArray = [[NSMutableArray alloc] init];
    }
    
    [tmpArray addObject:img];
    [dicUsers setObject:tmpArray forKey:forKey];
    
    [self.usersTableView reloadData];
}

- (UIImage *) resizeImag : (UIImage *) img{
   
    CGSize destinationSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContext(destinationSize);
    [img drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma  mark - contact list 
#pragma mark -
#pragma mark QBChatDelegate

- (void) getContactList {
    QBContactList * contactList = [QBChat instance].contactList;
}

- (void)chatContactListDidChange:(QBContactList *)contactList{
    NSLog(@"");
    [self userDidLogin];
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status{
    NSLog(@"");
    [self userDidLogin];
}

#pragma mark - online/offline status
- (void) checkUserStatus : (QBUUser *) user {
    
    NSInteger currenTime = [[NSDate date] timeIntervalSince1970];
    NSInteger userLastRequestAtTimeInterval = [[user lastRequestAt] timeIntervalSince1970];
    
    NSString * forKey = [NSString stringWithFormat:@"%lu", user.ID];

    if ((currenTime - userLastRequestAtTimeInterval) > (5 * 60)) {
        [dicUsers setObject:[NSNumber numberWithBool:NO] forKey:forKey];
    }
    else {
        [dicUsers setObject:[NSNumber numberWithBool:YES] forKey:forKey];
    }
    
}

@end
