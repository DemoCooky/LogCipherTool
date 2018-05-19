//
//  DatabaseHelper.h
//  LogCipherTool
//
//  Created by yanjing on 12/1/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface DatabaseHelper : NSObject

@property(nonatomic,strong)FMDatabase *fmdb;
@property(atomic,assign) BOOL isClose;

/**
 单例模式
 
 @param
 @param
 
 */
+ (DatabaseHelper *) sharedInstance;
/**
 创建内存数据表
 
 @param
 @param
 
 */
- (void)createLogTable;
/**
 删除 表中的数据
 
 @param  
 @param
 
 */
- (BOOL)deleLogData;
- (BOOL)closeDatabase;
- (BOOL)rollback;
/**
 向数据表中insert数据
 
 @param
 @param
 
 */
- (void)insertLogTime:(NSString *)logTime LogLevel:(NSString *)logLevel LogType:(NSString *)logType ThreadName:(NSString *)threadName logContent:(NSString*)logContent;
/**
 全查询
 
 @param
 @param
 
 */
- (void)queryLog;
/**
  查询并返回数据
 
 @param aInput NSString The encrypted content
 @param key  The secret key
 
 */
- (void)queryLog: (void (^)(id data))callback;
/**
 
 根据 logLevel 查询
 @param
 @param
 
 */
- (void)queryLogWithLogLevel:(NSString *)logLevel  callback:(void (^)(id data))callback;
/**
 模糊查询
 
 @param
 @param
 
 */

-(void) queryInFuzzy:(NSString *)keyword  callback:(void (^)(id data))callback;
/**
 判读是int类型
 
 @param
 @param
 
 */
- (BOOL)isPureInt:(NSString*)string;
/**
 判断浮点型
 
 @param
 @param
 
 */
- (BOOL)isPureFloat:(NSString*)string;

/**
 
 开始事务
 @param
 @param
 
 */
-(void)beginTransaction;
/**
 提交事务
 
 @param
 @param
 
 */
-(void)commit;

@end
