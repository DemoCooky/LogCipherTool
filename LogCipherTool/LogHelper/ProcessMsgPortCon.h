//
//  ProcessMsgPortCon.h
//  LogCipherTool
//
//  Created by yanjing on 12/8/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MACH_PORT_REMOTE    "com.machi.log"
#define MACH_NOTIFY_NAME    @"com.machi.log"


void(^callBackData)(id data, int index, NSError * error);

@interface ProcessMsgPortCon : NSObject{
     CFMessagePortRef  mMsgPortListenner;
     dispatch_semaphore_t semaphore ;
}
@property (readwrite, nonatomic, strong) NSLock *lock;
//  void(^callBackData)(id data, NSError * error);

/*
 send msg bymach port
 @param
 @param
 */
//-(NSString *)sendMessage:(id)msgInfo msgID:(int)msgid;
-(BOOL)sendMessage:(id)msgInfo msgID:(int)msgid;

/*
 startListenning
 
 @param
 @param
 */
- (void)startListening;

/*
 endLisenning
  
 @param
 @param
 */
- (void)endLisening;

/*
 单例
 
 @param
 @param
 */
+ (ProcessMsgPortCon *) sharedInstance;

/*
 远程通知add
 
 @param
 @param
 */
- (void)addNotifyListening;
/*
 
 远程通知 send
 
 @param
 @param
 */
- (void)sentNotifyMessage:(NSString *)object;
/*
 远程通知 remove
 
 @param
 @param
 */
- (void)removeNotifyListening;
@end
