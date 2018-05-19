//
//  RegexHelper.h
//  LogCipherTool
//
//  Created by yanjing on 12/3/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegexHelper : NSObject

/*
 正则 解析 log 内容
 
 @param
 @param
 */

+(NSMutableArray *)handleRegexString:(NSString *)content;

@end
