//
//  SQLiteMananger.m
//  WJ-IN-2014
//
//  Created by lion on 2/21/14.
//  Copyright (c) 2014 Matthias Lukjantschuk. All rights reserved.
//

#import "SQLiteMananger.h"

SQLiteMananger * _SQLiteManager;

@implementation SQLiteMananger

+ (SQLiteMananger *) SharedDataBase {
    
    if (_SQLiteManager ==  nil) {
    
        _SQLiteManager = [[SQLiteMananger alloc] init];
        
    }
    
    return _SQLiteManager;
    
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        NSString * sqLiteDb = [self getFilePath];
        
        [self createDatabase];
        
        if (sqlite3_open([sqLiteDb UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database");
        }
    }
    
    return self;
    
}

- (NSString *) getFilePath {
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString * file = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"database.db"]];
    
    return  file;

}

- (void) createDatabase {
    
    NSString * filePath;

    filePath = [self getFilePath] ;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:filePath] == NO)
    {
        const char *dbpath = [filePath UTF8String];
        
        if (sqlite3_open(dbpath, &database)==SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS MESSAGESTBL (ID INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, SENDERID TEXT, RECEIPIENT TEXT, MESSAGEDATE TEXT, MESSAGE TEXT)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
                 NSLog(@"Failded to create table");
            }
        }
        else
        {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (NSMutableArray *) getMessagesContent : (NSUInteger) seletedUserID {
    
    QBUUser * user = [LocalStorageService shared].currentUser;
    // reload table with users
    NSMutableArray * messageArray = [[NSMutableArray alloc] init];
    
    NSString * userId = [NSString stringWithFormat:@"%lu", (unsigned long)user.ID];
    NSString * receipientID = [NSString stringWithFormat:@"%lu", (unsigned long) seletedUserID];
    
    sqlite3_stmt * statement;
    NSString    * filePath = [self getFilePath];
    const char *dbpath = [filePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString * query = [NSString stringWithFormat:@"SELECT USERID, SENDERID, RECEIPIENT, MESSAGEDATE, MESSAGE from MESSAGESTBL where USERID=\"%@\" and (SENDERID=\"%@\" OR RECEIPIENT=\"%@\")", userId, receipientID, receipientID];
         const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
        
            while (sqlite3_step(statement) == SQLITE_ROW) {
            
                NSString * userID = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                NSString * receipientID = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                NSString * text = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
                NSString * strDate = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 4)];
                
                NSUInteger  lUserId = (NSUInteger)[userID longLongValue];
                NSUInteger  lReceipientID = (NSUInteger)[receipientID longLongValue];
                NSDate   * dateMessage;
            
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
            
                dateMessage = [formatter dateFromString:strDate];
            
                QBChatMessage * message = [[QBChatMessage alloc] init];
                message.senderID = lUserId;
                message.recipientID = lReceipientID;
                message.datetime = dateMessage;
                message.text = text;
            
                [messageArray addObject:message];
            }
        }
    }
    
    return messageArray;
}

- (void) insertDataMessage : (QBChatMessage *) message {

    QBUUser * user = [LocalStorageService shared].currentUser;
    
    NSString    * userID = [NSString stringWithFormat:@"%lu", (unsigned long) user.ID];
    
    NSString    * senderID;
    if (message.senderID <= 0) {
        senderID    =  userID;
    } else
        senderID    = [NSString stringWithFormat:@"%lu", (unsigned long)message.senderID];
    
    NSString    * receiveID = [NSString stringWithFormat:@"%lu", (unsigned long)message.recipientID];
    NSString    * strMessage= message.text;
    NSDate      * date      = message.datetime;
    NSString    * strDate;
    
    NSDateFormatter  * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    strDate = [formatter stringFromDate:date];

    NSString    * filePath = [self getFilePath];
    
    sqlite3_stmt *statement;
    
    const char *dbpath = [filePath UTF8String];
    
    if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO MESSAGESTBL (USERID, SENDERID, RECEIPIENT, MESSAGEDATE, MESSAGE) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",userID, senderID ,receiveID ,strMessage, strDate];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"Success");
        }
        else
        {
            NSLog(@"Error");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}


#pragma mark - store profile infor 

- (void) insertProfileinfo:(QBUUser *)user {
    
    NSString        * userID = [NSString stringWithFormat:@"%lu", (unsigned long) user.ID];
    NSString        * fullName  = user.fullName;
    NSString        * loginName = user.login;
    NSString        * email     = user.email;
    NSString        * phone     = user.phone;
    NSString        * website   = user.website;
    
//    NSMutableArray  * tags      = user.tags;

    [self createDatabaseForProfile];
    
    NSString    * filePath = [self getFilePath];
    
    sqlite3_stmt *statement;
    
    const char *dbpath = [filePath UTF8String];
    
    if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PROFILETBL (USERID, FULLNAME, LOGINNAME, EMAIL, PHONE, WEBSITE) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",userID, fullName ,loginName ,email, phone, website];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"Success");
        }
        else
        {
            NSLog(@"Error");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }

}


- (void) createDatabaseForProfile {
    
    NSString * filePath;
    
    filePath = [self getFilePath] ;
    
    const char *dbpath = [filePath UTF8String];
        
    if (sqlite3_open(dbpath, &database)==SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PROFILETBL (ID INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, FULLNAME TEXT, LOGINNAME TEXT, EMAIL TEXT, PHONE TEXT, WEBSITE TEXT)";
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
                NSLog(@"Failded to create table");
        }
    }
    else
    {
            NSLog(@"Failed to open/create database");
    }
}

@end
