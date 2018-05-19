//
//  LogHelpper.h
//  Mac Hi
//
//  Created by Scott Wu on 14-4-3.
//  Copyright (c) 2014年 baidu. All rights reserved.
//
#ifndef Log_Helper_h
#define Log_Helper_h

#endif

#define kDefaultUploadFileMaxCount 1
//
//#import "RollingFileLogger.h"
#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, LogLevel)
{
    LOGLEVEL_DEBUG=0,
    LOGLEVEL_INFO,
    LOGLEVEL_WARNING,
    LOGLEVEL_ERROR
};


//typedef void (^FinishBlock)(NSString *dataString);

@class HIIMSPacket;

static BOOL isBreak ;
@interface LogHelper : NSObject

@property (copy, nonatomic) void(^refreshViewBlock)(id data, NSError * error);
@property (readonly) NSString* logFolder;
@property (nonatomic, strong) NSObject * lockHelper;

+(void)appendToFileWithData:(NSData *)content inFile:(NSString *)filePath;
+(BOOL)prepareLogFileToWrite:(NSString *)filePath;
+(void)closeDB;
@end
