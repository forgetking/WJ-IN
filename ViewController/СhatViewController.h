//
//  СhatViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface ChatViewController : UIViewController

@property (nonatomic, strong) QBUUser *opponent;
@property (nonatomic, strong) QBChatRoom *chatRoom;


@end
