//
//  LogHelper+Cipher.m
//  LogCipherTool
//
//  Created by yanjing on 11/27/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "LogHelper+Cipher.h"
#import "RC4Cipher.h"
#import "ByteAndInt.h"
#import "LogHelper.h"
#import "DatabaseHelper.h"
#import "RegexHelper.h"
#import "HiLog.h"
#import "ProcessMsgPortCon.h"


@implementation LogHelper (Cipher)

+(void)closeDB{
    
    [[DatabaseHelper sharedInstance]closeDatabase];

}

+(void)readDataInFile:(NSString*)filePath block:(FinishBlock)callblock{
 
    if (filePath ==  nil || filePath.length == 0) {
        return;
    }
 
    __weak typeof (self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;

        __block int fileSize = [LogHelper getFileSize:filePath];
        __block int headerLength = 4;
        __block int headerStartPostion = 0;
        __block int contentStartPostion = 4;
        
            int index = 0;
             [[DatabaseHelper sharedInstance]deleLogData];
             [[DatabaseHelper sharedInstance]beginTransaction];
            while(1){
                @autoreleasepool {
                    
                    if ([DatabaseHelper sharedInstance].isClose) {
                        NSLog(@"------ db is closed  ------- ");
                        break;
                    }
                    index ++;
                    if(headerStartPostion >= fileSize || contentStartPostion >= fileSize || headerLength >= fileSize)
                    {
                        NSLog(@"------ break 1.  read finish ! ------- " );
                        break;
                    }
                    
                    NSData * Header = [strongSelf readDataInFileFromOffset:headerStartPostion length:headerLength inFile:filePath];
                    byte * lenby = (byte *)[Header bytes];
                    int contentLength = [ByteAndInt bytesToInt:lenby];
 
                    if(contentLength > fileSize || contentLength <= 0) {
                        {
                            int oldStart = headerStartPostion;
                            //容错
                            while (headerStartPostion < fileSize) {
                                headerStartPostion++;
                                NSData * Header = [strongSelf readDataInFileFromOffset:headerStartPostion length:headerLength inFile:filePath];
                                byte * lenby = (byte *)[Header bytes];
                                contentLength = [ByteAndInt bytesToInt:lenby];
                                if (contentLength > fileSize || contentLength <= 0) continue;
                                contentStartPostion = headerStartPostion + headerLength;
                                NSData * content = [strongSelf readDataInFileFromOffset:contentStartPostion length:contentLength inFile:filePath];
                                NSString * target ;
                                if([[self class]stringTagert:filePath containsString:@"secrettrace"])
                                {
//                                if ([filePath containsString:@"secrettrace"]) {
                                    target = [RC4Cipher OldRC4DecryteWithNSDataOrign:content key:RC4_Key];
                                }else{
                                    target = [RC4Cipher RC4DecryteWithNSDataOrign:content key:RC4_Key];
                                }
                                if ([target rangeOfString:@"][20"].location != NSNotFound) {
                                    break;
                                }
                            }
//                            NSLog(@"------ break 2.  容错，跳过：%d! ------- ",(headerStartPostion-oldStart));
                            {
                            }
                        }
                        if (contentLength > fileSize || contentLength <= 0) {
                            NSLog(@"------ break 2.  read finish ! ------- ");
                            break;
                        }
                    }
                    contentStartPostion = headerStartPostion + headerLength;
                    NSData * content = [strongSelf readDataInFileFromOffset:contentStartPostion length:contentLength inFile:filePath];
                    headerStartPostion = headerStartPostion + contentLength + headerLength;
                    //contentStartPostion = headerStartPostion + headerLength;
                    NSString * target ;
//                    if ([filePath containsString:@"secrettrace"]) {
                    
                    if([[self class]stringTagert:filePath containsString:@"secrettrace"])
                    {
                        target = [RC4Cipher OldRC4DecryteWithNSDataOrign:content key:RC4_Key];
                    }else{
                        target = [RC4Cipher RC4DecryteWithNSDataOrign:content key:RC4_Key];
                    }

//                    if ([filePath containsString:@"secrettrace"]) {
//                        target = [RC4Cipher OldRC4DecryteWithNSDataOrign:content key:RC4_Key];
//                    }else{
//                        target = [RC4Cipher RC4DecryteWithNSDataOrign:content key:RC4_Key];
//                        
//                    }
                    HiLog * hiLog = [strongSelf handleLogStringToArray:target Squence:index];
                    [[DatabaseHelper sharedInstance] insertLogTime:hiLog.logTime LogLevel:hiLog.logLevel LogType:hiLog.logType ThreadName:hiLog.threadName logContent:hiLog.logContent];
                 
                 }

            }
        if ([DatabaseHelper sharedInstance].isClose) {
            [[DatabaseHelper sharedInstance]rollback];
            if (callblock != nil ) {
                callblock(nil);
            }
        }else{
            [[DatabaseHelper sharedInstance]commit];
            [[DatabaseHelper sharedInstance]queryLog:^(id data) {
                if (callblock != nil && data != nil) {
                    callblock(data);
                }
            }];
        }
       
    });// end block dispatch;
    
}

+(BOOL)stringTagert:(NSString *)oldString containsString:(NSString*)subString {
    BOOL  res = NO;
    NSRange foundObj=[oldString rangeOfString:subString options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
         res = YES;
     } else {
         res = NO;
    }
    
    return res;
}

+(void)readDataInPortWithBlock:(FinishBlock)callblock
{
    [[DatabaseHelper sharedInstance]createLogTable];
    [[ProcessMsgPortCon sharedInstance]startListening];
 
    __weak typeof (self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
 
            callBackData = ^(id data, int index, NSError * error){
                HiLog * hiLog = [strongSelf handleLogStringToArray:data Squence:index];
                [[DatabaseHelper sharedInstance]insertLogTime:hiLog.logTime LogLevel:hiLog.logLevel LogType:hiLog.logType ThreadName:hiLog.threadName logContent:hiLog.logContent];
                [[DatabaseHelper sharedInstance]queryLog:^(id data) {
                    if (data) {
                        callblock(data);
                    }
                }];
            };
 
    });
    
 }

+(void)readDataInPortEndListening
{
    [[ProcessMsgPortCon sharedInstance]endLisening];
 }

+(int)getFileSize:(NSString*)filePath{
    NSFileManager * filemanager = [NSFileManager defaultManager] ;
    int fileSize = 0;
    NSDictionary * attributes = [filemanager attributesOfItemAtPath:filePath error:nil];
    NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
    if (theFileSize ){
        fileSize = [theFileSize intValue];
    }
    return fileSize;
}



+(HiLog *)handleLogStringToArray:(NSString *) target  Squence:(int)squence{
 

    NSMutableArray *targetArray = [RegexHelper handleRegexString:target];

    NSString * logTime = nil;
    NSString * logLevel = nil;
    NSString * logContent = nil;
    NSString * logType = nil;
    NSString * threadName = nil;
    
    int ID = squence;
        HiLog *hiLog = [[HiLog alloc]init];
    if (targetArray == nil ) {
        NSLog(@" 空 log ");
    }else{
        if (targetArray.count > 4) {
            logContent = [targetArray objectAtIndex:4];
        }
        if (targetArray.count > 3) {
            threadName = [targetArray objectAtIndex:3];
        }
        if (targetArray.count > 2) {
            logTime = [targetArray objectAtIndex:2];
        }
        if (targetArray.count > 1) {
            logType = [targetArray objectAtIndex:1];
        }
        
        if (targetArray.count > 0) {
            logLevel = [targetArray objectAtIndex:0];
        }
        hiLog.ID = ID;
        hiLog.logContent = logContent;
        hiLog.logLevel = logLevel;
        hiLog.logTime = logTime;
        hiLog.logType = logType;
        hiLog.threadName = threadName;
    }
    
    return hiLog;
}

+(NSData *)readDataInFileFromOffset:(unsigned long long)offset length:(NSUInteger)length inFile:(NSString*)filePath{
    NSData *filedata = nil;

    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:offset];
    filedata = [handle readDataOfLength:length];
    [handle closeFile];

    return filedata;
}

+(NSString*)getFileDirectory{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString *  _logFolder = [documentsDirectory stringByAppendingPathComponent:@"BaiduMacHi/Share/App/Log"];
    return _logFolder;
}


@end
