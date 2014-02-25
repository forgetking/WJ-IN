//
//  DEMOMenuViewController.m
//  REFrostedViewControllerStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "WJMenuViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "WJNavigationController.h"
#import "UsersViewController.h"
#import "ChatRoomsViewController.h"
#import "PDFWebViewController.h"
#import "MapViewController.h"
#import "WJSettingsViewController.h"


@interface WJMenuViewController () <QBActionStatusDelegate> {
    UIImageView *imageView;
}

@end

@implementation WJMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"pGuendisch.png"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        
        label.text = [LocalStorageService shared].currentUser.fullName;;//  @"Patrick Gündisch";
        
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    [self onDownloadAvatarImage];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Kontackte online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WJNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UsersViewController *userViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userviewcontroller"];
        navigationController.viewControllers = @[userViewController];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        
        ChatRoomsViewController *chatRoomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatroomviewcontroller"];
        navigationController.viewControllers = @[chatRoomViewController];
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        
        PDFWebViewController *pdfWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pdfwebviewcontroller"];
        navigationController.viewControllers = @[pdfWebViewController];
        
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        
        MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapviewcontroller"];
        navigationController.viewControllers = @[mapViewController];
        
    } else if (indexPath.section == 0 && indexPath.row == 4) {
        
        WJSettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsviewcontroller"];
        navigationController.viewControllers = @[settingsViewController];
        
    }
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *titles = @[@"User", @"Konferenz", @"Jahrbuch", @"WJ-Map", @"Einstellungen"];
    cell.textLabel.text = titles[indexPath.row];

    return cell;
}

#pragma  mark - download Image  

- (void) completedWithResult:(Result *)result {
    
    if (result.success) {
        if ([result isKindOfClass:[QBCFileDownloadTaskResult class]]) {
            
            QBCFileDownloadTaskResult *res  = (QBCFileDownloadTaskResult *) result;
            UIImage * img = [[UIImage alloc] initWithData:res.file];
            [self setAvatarImage:img];
            
        }
    }
}
- (void) onDownloadAvatarImage {
    
    NSUInteger userProfilePictureID = [LocalStorageService shared].currentUser.blobID;
    
    [QBContent TDownloadFileWithBlobID:userProfilePictureID delegate:self];
}

- (void) setAvatarImage : (UIImage *) img {
    [imageView setImage:img];
}
@end
