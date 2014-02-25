//
//  SplashViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController () <QBActionStatusDelegate>

@end

@implementation SplashViewController

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
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
	[QBAuth createSessionWithDelegate:self];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            
            // retrieve users' points
            // create QBLGeoDataSearchRequest entity
            QBLGeoDataGetRequest *getRequest = [[QBLGeoDataGetRequest alloc] init];
            //getRequest.lastOnly = YES; // Only last location
            getRequest.perPage = 70; // only 70 points
            getRequest.sortBy = GeoDataSortByKindCreatedAt;
            
            // retieve user's points
            [QBLocation geoDataWithRequest:getRequest delegate:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                            message:[result.errors description]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }   else if ([result isKindOfClass:[QBLGeoDataPagedResult class]]) {
        
        // Success result
        if (result.success) {
            // Hide splash & show main controller
            QBLGeoDataPagedResult *geoDataGetRes = (QBLGeoDataPagedResult *)result;
            [DataManager shared].checkinArray  = [geoDataGetRes.geodata mutableCopy];
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // hide splash
//                [self dismissViewControllerAnimated:YES completion:nil];
                [self gotoLoginViewController];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
            });
        }
    }
}

- (void) gotoLoginViewController {
    [self performSegueWithIdentifier:kShowLoginViewControllerSegue sender:nil];
}

@end
