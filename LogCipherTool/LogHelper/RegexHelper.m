//
//  RegexHelper.m
//  LogCipherTool
//
//  Created by yanjing on 12/3/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "RegexHelper.h"

@implementation RegexHelper


+(NSMutableArray *)handleRegexString:(NSString *)content{
    
//    NSString *log = @"[75015:4604780544][2014-12-02 20:03:26.829][DEBUG] >>>startTimeout <TimeoutableCallback: 0x600000445df0>\r\nabc";
    
    NSString *log = @"[Debug][HiCore][2018/05/09 16:46:28:547][com.apple.root.default-qos.overcommit] virtual void LogCallback::d(const char *, int) Line:391 [16:46:28.547]handleReadDone, read 200 bytes,                total=26820 ";
    
    NSString *pattern = @"\\[([^]]+)\\]\\[([^]]+)\\]\\[([^]]+)\\]\\[([^]]+)\\](.+)";
    
    
    if (content == nil) {
        return nil;
    }
    
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSArray *matches = [exp matchesInString:content options:0 range:NSMakeRange(0, [content length])];
    
    NSMutableArray *targetArray = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        NSUInteger count = [match numberOfRanges];
        for (int i = 1; i < count; i++) {
            NSRange matchRange  = [match rangeAtIndex:i];
            NSString *matchString = [content substringWithRange:matchRange];
            matchString = [matchString stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
           [targetArray addObject:matchString];
        }
    }
    return targetArray;
}

@end
