//
//  HiLog.h
//  LogCipherTool
//
//  Created by yanjing on 12/4/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HiLog : NSObject

@property(nonatomic,strong) NSString *logTime;
@property(nonatomic,strong) NSString *logLevel;
@property(nonatomic,strong) NSString *logContent;
@property(nonatomic,strong) NSString *logType;
@property(nonatomic,strong) NSString *threadName;
@property(nonatomic,assign) int ID ;

@end
