//
//  ByteAndInt.h
//  LogCipherTool
//
//  Created by yanjing on 11/26/14.
//  Copyright (c) 2014 com.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef TYPE_BYTE
#define TYPE_BYTE
typedef unsigned char byte;
#endif

#ifndef TYPE_UINT
#define TYPE_UINT
typedef unsigned int uint;
#endif


@interface ByteAndInt : NSObject


/**
 int转byte
 
 @param int value
 @param  out param
 
 */
//int转byte
+(byte *)startInt:(int)iValue ToByte:(byte *)bytes;

+(byte *)IntToByte:(int)iValue;

/**
 byte转int
 
 @param
 @param
 
 */

+(int)bytesToInt:(byte* )bytes;

+(int)BytesToInt:(Byte* )bytes;
@end




//void intToByte(int i, byte *bytes)
//{
//    int tp = sizeof(byte);
//    int size = 4;
//    //byte[] bytes = new byte[4];
//    memset(bytes,0,tp * size);
//    bytes[0] = (byte) (0xff & i);
//    bytes[1] = (byte) ((0xff00 & i) >> 8);
//    bytes[2] = (byte) ((0xff0000 & i) >> 16);
//    bytes[3] = (byte) ((0xff000000 & i) >> 24);
//    return ;
//}
//
////byte转int
//int bytesToInt(byte* bytes)
//{
//    int size = 4;
//    int addr = bytes[0] & 0xFF;
//    addr |= ((bytes[1] << 8) & 0xFF00);
//    addr |= ((bytes[2] << 16) & 0xFF0000);
//    addr |= ((bytes[3] << 24) & 0xFF000000);
//    return addr;
//}
