//
//  LogConViewController.m
//  LogCipherTool
//
//  Created by yanjing on 12/3/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import "LogConViewController.h"

@interface LogConViewController ()

@end

@implementation LogConViewController

- (void) awakeFromNib
{
    NSLog(@"--------");
    self.logContentView.string =  self.logContent;
}


-(void)setlogText:(NSString*)text{
    self.logContentView.string = text;
}


@end
