//
//  RC4Cipher.h
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RC4_Key  @"ioshilogerencypt"
 
@interface RC4Cipher : NSObject


//+(NSString*)startRC4WithOrign:(NSString*)aInput key:(NSString*)aKey;

/**
 RC4 加密
 
 @param aInput NSString The encrypted content
 @param key  The secret key
 
 */
+(NSString*)RC4EncryteWithOrign:(NSString*)aInput key:(NSString*)aKey;
/**
 RC4 解密
 
 @param aInput  NSString The encrypted content
 @param key  The secret key
 
 */
+(NSString*)RC4DecryteWithOrign:(NSString*)aInput key:(NSString*)aKey;

/**
 RC4 解密
 
 @param aInput  NSData  The encrypted content
 @param key  The secret key
 
 */
+(NSString*)RC4EncryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey;

/**
 RC4 解密
 
 @param aInput NSData  The encrypted content
 @param key  The secret key
 
 */
+(NSString*)RC4DecryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey;


+(NSString*)OldRC4DecryteWithNSDataOrign:(NSData*)aInput key:(NSString*)aKey;

@end
