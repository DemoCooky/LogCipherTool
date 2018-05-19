//
//  LogConViewController.h
//  LogCipherTool
//
//  Created by yanjing on 12/3/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LogConViewController : NSViewController

@property (strong) IBOutlet NSTextView * logContentView;
@property (strong) NSString * logContent;

-(void)setlogText:(NSString*)text;


@end
