//
//  LogHelper+Cipher.h
//  LogCipherTool
//
//  Created by yanjing on 11/27/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "LogHelper.h"
#import "RegexHelper.h"
@class HiLog;

typedef void (^FinishBlock)(id data);

@interface LogHelper (Cipher)
/*
 
 读文件根据偏移量
 @param
 @param
 */
+(NSString *)readDataWithHeaderLength:(int)headerLength headerStartPostion:(int)headerStartPostion contentStartPostion:(int)contentStartPostion;
/*
 读取文件
 
 @param
 @param
 */
+(void)readDataInFile:(NSString*)filePath block:(FinishBlock)callblock;
/*
 读取文件
 
 @param
 @param
 */
+(void)readDataInPort:(NSString *)target withIndex:(int)index Block:(FinishBlock)callblock;


/*
 读取文件
 
 @param
 @param
 */

+(void)readDataInPortWithBlock:(FinishBlock)callblock;
/*

 停止监听
 @param
 @param
 */
+(void)readDataInPortEndListening;

/*
 得到文件大小
 
 @param
 @param
 */
+(int)getFileSize:(NSString*)filePath;
/*
 分解 log string 成为一个 数组
 
 @param
 @param
 */
+(void)handleLogStringToArray:(NSString *) target;
+(HiLog *)handleLogStringToArray:(NSString *) target  Squence:(int)squence;

/*
 得到文件目录
 
 @param
 @param
 */

+(NSString*)getFileDirectory;

@end
