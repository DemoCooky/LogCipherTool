//
//  ViewController.h
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ExportMenu.h"

@class PopViewController,LogConViewController;
@class DragDropTableView;
@class ProcessMsgPortCon;

@interface ViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate,NSComboBoxDataSource,NSComboBoxDelegate,NSPopoverDelegate,ExportMenuDelegate>{
    // config UI
//      IBOutlet NSMatrix *popoverType;
//      IBOutlet NSMatrix *popoverPosition;
    
      dispatch_source_t timer;
      dispatch_queue_t  queOutput;
}

@property (strong,nonatomic) IBOutlet NSTextView * logView;
@property (strong,nonatomic) IBOutlet DragDropTableView  * logTableView;
@property (strong,nonatomic) NSArray * logList;
@property (strong,nonatomic) NSMutableArray * logLevelItems;
//@property (strong,nonatomic) NSString * logContent;
@property (strong) IBOutlet  NSComboBox *logCombobox;
@property (strong) IBOutlet  NSPopUpButton *logLevelPopBtn;
@property (strong) IBOutlet  NSPopover *detailPopover;
@property (strong,nonatomic) IBOutlet NSTextField * fuzzyFeild;
@property (strong,nonatomic) IBOutlet NSTextField * filePathLabel;
@property (strong,nonatomic) IBOutlet NSTextField * logCountlabel;
@property (strong,nonatomic) ProcessMsgPortCon * msgPortCon;
@property (strong,nonatomic) LogConViewController * popViewController;
@property (assign,nonatomic) BOOL isImLog;
@property (strong,nonatomic) IBOutlet NSButton * imLogBtn;
@property (strong,nonatomic) IBOutlet NSTextField * outputLabel;

@property (strong,nonatomic) IBOutlet NSButton * refreshBtn;

@property (assign,nonatomic)  BOOL  done;

@property (assign,nonatomic)  BOOL  isloadOk;

@property (strong,nonatomic) NSLock * lock;

@property (assign,nonatomic)  BOOL  isInSearchMode;

@property (strong) IBOutlet NSTextView * logContentView;
@property (strong) NSString * logContent;

-(void)setlogText:(NSString*)text;

@end

