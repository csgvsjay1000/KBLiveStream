//
//  KBStreamingBuffer.m
//  KBLiveStream
//
//  Created by chengshenggen on 7/1/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBStreamingBuffer.h"

static const NSUInteger defaultSortBufferMaxCount = 10;///< 排序10个内
static const NSUInteger defaultUpdateInterval = 1;///< 更新频率为1s
static const NSUInteger defaultCallBackInterval = 5;///< 5s计时一次
static const NSUInteger defaultSendBufferMaxCount = 600;///< 最大缓冲区为600

@interface KBStreamingBuffer (){
    dispatch_semaphore_t _lock;

}

@property (nonatomic, strong) NSMutableArray <KBFrame*>*sortList;
@property (nonatomic, strong, readwrite) NSMutableArray <KBFrame*>*list;
@property (nonatomic, strong) NSMutableArray *thresholdList;

/** 处理buffer缓冲区情况 */
@property (nonatomic, assign) NSInteger currentInterval;
@property (nonatomic, assign) NSInteger callBackInterval;
@property (nonatomic, assign) NSInteger updateInterval;
@property (nonatomic, assign) BOOL startTimer;

@end

@implementation KBStreamingBuffer

- (instancetype)init{
    if(self = [super init]){
        _lock = dispatch_semaphore_create(1);
        self.updateInterval = defaultUpdateInterval;
        self.callBackInterval = defaultCallBackInterval;
        self.maxCount = defaultSendBufferMaxCount;
    }
    return self;
}

#pragma mark -- Custom
- (void)appendObject:(KBFrame*)frame{
    if(!frame) return;
    if(!_startTimer){
        _startTimer = YES;
//        [self tick];
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if(self.sortList.count < defaultSortBufferMaxCount){
        [self.sortList addObject:frame];
    }else{
        ///< 排序
        [self.sortList addObject:frame];
        NSArray *sortedSendQuery = [self.sortList sortedArrayUsingFunction:frameDataCompare context:NULL];
        [self.sortList removeAllObjects];
        [self.sortList addObjectsFromArray:sortedSendQuery];
        
    }
    
    
}


NSInteger frameDataCompare(id obj1, id obj2, void *context){
    KBFrame* frame1 = (KBFrame*) obj1;
    KBFrame *frame2 = (KBFrame*) obj2;
    
    if (frame1.timestamp == frame2.timestamp)
        return NSOrderedSame;
    else if(frame1.timestamp > frame2.timestamp)
        return NSOrderedDescending;
    return NSOrderedAscending;
}

@end
