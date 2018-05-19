//
//  LogHelpper.m
//  Mac Hi
//
//  Created by Scott Wu on 14-4-3.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "LogHelper.h"
#import "RC4Cipher.h"
#import "ByteAndInt.h"
#import "DatabaseHelper.h"
#import <pthread.h>


@interface LogHelper()
//+(NSString*)stringForLevel: (LogLevel) level;
@end





@implementation LogHelper
- (instancetype)init
{
    self = [super init];
    if (self) {
        //Setup log folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _logFolder = [documentsDirectory stringByAppendingPathComponent:@"BaiduMacHi/Share/App/Log"];
    
        self.lockHelper = [[NSObject alloc]init];
        
    }
    return self;
}

-(NSString *)defaultLogFile
{
    return [self.logFolder stringByAppendingPathComponent:@"outputtrace.log"];
}

-(NSString*)getLogFileAtIndex:(int)index
{
    if(index > 0){
        return [self.logFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"outputtrace%lu.log", (unsigned long)index]];
    }else{
        return self.defaultLogFile;
    }
}

+(BOOL)prepareLogFileToWrite:(NSString *) filePath
{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
//        return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
//    }else  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
//        return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
//    }
//    
//    return YES;
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];

}

+(void)appendToFileWithData:(NSData *)content inFile:(NSString *)filePath
{
//    if ([[self class] prepareLogFileToWrite:filePath]) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [handle truncateFileAtOffset:[handle seekToEndOfFile]];
        [handle writeData:content];
        [handle closeFile];
//    }
    
}

@end
