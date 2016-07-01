//
//  KBStreamingBuffer.h
//  KBLiveStream
//
//  Created by chengshenggen on 7/1/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBVideoFrame.h"

/** current buffer status */
typedef NS_ENUM(NSUInteger, LFLiveBuffferState) {
    LFLiveBuffferUnknown = 0,      //< 未知
    LFLiveBuffferIncrease = 1,    //< 缓冲区状态好可以增加码率
    LFLiveBuffferDecline = 2      //< 缓冲区状态差应该降低码率
};

@class KBStreamingBuffer;
/** this two method will control videoBitRate */
@protocol LFStreamingBufferDelegate <NSObject>
@optional
/** 当前buffer变动（增加or减少） 根据buffer中的updateInterval时间回调*/
- (void)streamingBuffer:(KBStreamingBuffer *)buffer bufferState:(LFLiveBuffferState)state;
@end

@interface KBStreamingBuffer : NSObject

/** The delegate of the buffer. buffer callback */
@property (nonatomic, weak) id <LFStreamingBufferDelegate> delegate;

/** current frame buffer */
@property (nonatomic, strong, readonly) NSMutableArray <KBFrame*>* list;

/** buffer count max size default 1000 */
@property (nonatomic, assign) NSUInteger maxCount;

/** add frame to buffer */
- (void)appendObject:(KBFrame*)frame;

/** pop the first frome buffer */
- (KBFrame*)popFirstObject;

/** remove all objects from Buffer */
- (void)removeAllObject;

@end
