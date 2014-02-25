//
//  WJSettingsViewController.m
//  WJ-IN-2014
//
//  Created by lion on 2/24/14.
//  Copyright (c) 2014 Matthias Lukjantschuk. All rights reserved.
//

#import "WJSettingsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WJSettingsViewController () <CLLocationManagerDelegate, QBActionStatusDelegate> {
    CLLocationManager   * locationManager;
    CLGeocoder          * geoCoder;
    CLPlacemark         * placeMark;
}

@end

@implementation WJSettingsViewController

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

    [self locationManagerInitiMethod];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];// [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"Profile";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self performSegueEditProfile];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)onClickMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void) performSegueEditProfile {
    [self performSegueWithIdentifier:kShowEditViewController sender:nil];
}


#pragma mark - CLLOcationManager 

- (void) locationManagerInitiMethod {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    geoCoder = [[CLGeocoder alloc] init];
    [locationManager startUpdatingLocation];
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Getting locaiton information error : %@", error);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if ([locations count] > 0) {
        CLLocation * currentLocation = [locations objectAtIndex:0];
        NSLog(@"current location %@", currentLocation);
        
        [self   peopleCheckIn :  currentLocation]; // People Check in
        
        [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray * placeMarks, NSError * error){
            if (!error && ([placeMarks count] > 0)) {
                placeMark = [placeMarks lastObject];
                NSString * locationString = [NSString stringWithFormat:
                                             @"%@, %@",
                                             placeMark.administrativeArea,
                                             placeMark.country
                                             ];
                NSLog(@"current location %@", locationString);
            }
        }];
    }
}

#pragma mark - QBGeoData
- (void) peopleCheckIn : (CLLocation *) location {
    
    QBLGeoData * geoData = [QBLGeoData geoData];
    
    geoData.latitude = location.coordinate.latitude;
    geoData.longitude = location.coordinate.longitude;
    geoData.status = @"I am at QuickBlox house";
    
    [QBLocation createGeoData:geoData delegate:self];
    
}

- (void) completedWithResult:(Result *)result {
    
    if (result.success) {
        if ([result isKindOfClass:[QBLGeoDataResult class]]) {
            QBLGeoDataResult * checkinResult = (QBLGeoDataResult *) result;
            NSLog(@"Your checkin %@",checkinResult.geoData);
        }
        else {
            NSLog(@"Check error = %@", result.errors);
        }
    }
    
}
@end
