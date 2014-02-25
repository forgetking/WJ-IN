//
//  SQLiteMananger.h
//  WJ-IN-2014
//
//  Created by lion on 2/21/14.
//  Copyright (c) 2014 Matthias Lukjantschuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface SQLiteMananger : NSObject {
    
    sqlite3 * database ;
//    sqlite3 *contactDB;
    NSString *databasePath;
}

+ (SQLiteMananger *) SharedDataBase ;
- (void) insertDataMessage : (QBChatMessage *) message;
- (NSMutableArray *) getMessagesContent : (NSUInteger) seletedUserID;

- (void) insertProfileinfo : (QBUUser *) user ;

@end
