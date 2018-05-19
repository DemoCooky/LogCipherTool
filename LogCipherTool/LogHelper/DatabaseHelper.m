//
//  DatabaseHelper.m
//  LogCipherTool
//
//  Created by yanjing on 12/1/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "DatabaseHelper.h"
#import "FMDatabase.h"
#import "HiLog.h"

@implementation DatabaseHelper

static DatabaseHelper * sharedDbHelper = nil;

+ (DatabaseHelper *) sharedInstance
{    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedDbHelper == nil) {
            sharedDbHelper = [[DatabaseHelper alloc] init];
        }
    });
    return sharedDbHelper;
}


-(void)createLogTable{
   [self closeDatabase];
    self.fmdb = [FMDatabase databaseWithPath:nil];
    
    if ([self openDatabase]) {
        //4.创表
        BOOL result=[self.fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS HiLog (id integer PRIMARY KEY AUTOINCREMENT, logTime text, logLevel text, logType text ,threadName text,logContent text);"];
        if(result) {
            NSLog(@"创表成功");
        }else{
            NSLog(@"创表失败");
        }
    }
}

-(BOOL)deleLogData{
    
    if ([self.fmdb open]) {
        return [self.fmdb executeUpdate:@"DELETE FROM HiLog ;"];
    }
    
    return NO;
}

-(BOOL)closeDatabase{
     self.isClose =[self.fmdb close];
     return self.isClose;
}

-(BOOL)openDatabase{
    BOOL isOpen = [self.fmdb open];
    self.isClose = !isOpen;
    return isOpen;
 }

-(BOOL)rollback {
  return [self.fmdb rollback];
}

-(void)beginTransaction{
    [self.fmdb beginTransaction];
}

-(void)commit{
    [self.fmdb commit];

}
//插入数据
-(void)insertLogTime:(NSString *)logTime LogLevel:(NSString *)logLevel LogType:(NSString *)logType ThreadName:(NSString *)threadName logContent:(NSString*)logContent{
    // [NSString stringWithFormat:@"jack-%d", arc4random_uniform(100)];
    // executeUpdate : 不确定的参数用?来占位
//    if ([self.fmdb open]) {
        [self.fmdb executeUpdate:@"INSERT INTO HiLog (logTime,logLevel, logType, threadName, logContent) VALUES (?,?,?,?,?);", logTime,logLevel,logType,threadName,logContent];
//    }
}


//查询结果解析
-(NSMutableArray*)getQueryResults:(FMResultSet *) resultSet{
    
    NSMutableArray * array = [NSMutableArray array];
    // 遍历结果
    while ([resultSet next]) {
        @autoreleasepool {
            int ID = [resultSet intForColumn:@"id"];
            NSString *logTime = [resultSet stringForColumn:@"logTime"];
            NSString *logLevel = [resultSet stringForColumn:@"logLevel"];
            NSString *logType = [resultSet stringForColumn:@"logType"];
            NSString *threadName = [resultSet stringForColumn:@"threadName"];
            NSString *logContent = [resultSet stringForColumn:@"logContent"];
            
            HiLog *hiLog = [[HiLog alloc]init];
            hiLog.ID = ID;
            hiLog.logContent = logContent;
            hiLog.logLevel = logLevel;
            hiLog.logTime = logTime;
            hiLog.logType = logType;
            hiLog.threadName = threadName;
            [array addObject:hiLog];
        }
        
    }
    
    return array;
}
//查询结果解析
-(void)getQueryResults:(FMResultSet *)resultSet callback:(void (^)(id data))callback{
    
    NSMutableArray * array = [NSMutableArray array];
    int index = 0;
    
    // 遍历结果
    while ([resultSet next]) {
        
        @autoreleasepool {
            index ++;
            
            int ID = [resultSet intForColumn:@"id"];
            NSString *logTime = [resultSet stringForColumn:@"logTime"];
            NSString *logLevel = [resultSet stringForColumn:@"logLevel"];
            NSString *logType = [resultSet stringForColumn:@"logType"];
            NSString *threadName = [resultSet stringForColumn:@"threadName"];
            NSString *logContent = [resultSet stringForColumn:@"logContent"];
            
            HiLog *hiLog = [[HiLog alloc]init];
            hiLog.ID = ID;
            hiLog.logContent = logContent;
            hiLog.logLevel = logLevel;
            hiLog.logTime = logTime;
            hiLog.logType = logType;
            hiLog.threadName = threadName;
            [array addObject:hiLog];
        }
    }
    callback(array);
}

//查询
- (void)queryLog: (void (^)(id data))callback
{
 //    if ([self openDatabase]){
        //执行查询语句
        
         FMResultSet *resultSet = [self.fmdb executeQuery:@"SELECT * FROM HiLog"];
         NSMutableArray * array = [self getQueryResults:resultSet];
         callback(array);
//     }
}

//查询
- (void)queryLogWithLogLevel:(NSString *)logLevel  callback:(void (^)(id data))callback
{
    if ([logLevel isEqualToString:@"NONE"]) {
        return ;
    }
    
//    if ([self openDatabase]){
        //执行查询语句
        FMResultSet *resultSet = [self.fmdb executeQuery:@"SELECT * FROM HiLog where  logLevel = ?", logLevel];
        NSMutableArray * array = [self getQueryResults:resultSet];
        callback(array);
//    }
}

//模糊查询
-(void) queryInFuzzy:(NSString *)keyword callback:(void (^)(id data))callback
{
    if(keyword == nil  || keyword.length == 0){
        
    }else{
//        if ([self openDatabase]){
            //执行查询语句
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM HiLog where logContent LIKE '%%%@%%' OR logTime LIKE '%%%@%%'  OR logType LIKE '%%%@%%' OR logLevel LIKE '%%%@%%' OR threadName LIKE '%%%@%%'"  ,keyword,keyword,keyword,keyword,keyword];
            FMResultSet *resultSet = [self.fmdb executeQuery:sql];
            NSMutableArray * array = [self getQueryResults:resultSet];
            callback(array);
//        }

    }
}

//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


//判断是否为浮点形：
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
