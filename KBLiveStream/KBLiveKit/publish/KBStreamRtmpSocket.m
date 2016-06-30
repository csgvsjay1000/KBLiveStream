//
//  KBStreamRtmpSocket.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/30/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBStreamRtmpSocket.h"
#import "rtmp.h"

@interface KBStreamRtmpSocket (){
    PILI_RTMP *_rtmp;
    
}

@property(nonatomic,weak)id<KBStreamSocketDelegate> delegate;
@property(nonatomic,strong)KBLiveStreamInfo *stream;
@property(nonatomic,strong)dispatch_queue_t socketQueue;

@property(nonatomic,assign)RTMPError error;

@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isReconnecting;

@end

@implementation KBStreamRtmpSocket

-(id)initWithStream:(KBLiveStreamInfo *)stream{
    self = [super init];
    if (self) {
        _stream = stream;
    }
    return self;
}

#pragma mark - rtmp manager
-(void)start{
    dispatch_async(self.socketQueue, ^{
        if (!_stream) return ;
        if(_isConnecting)return;
        if(_rtmp != NULL)return;
        [self RTMP264_Connect:(char*)[_stream.url cStringUsingEncoding:NSASCIIStringEncoding]];
    });
}

-(void)stop{
    
}

-(void)clean{
    _isConnecting = NO;
    _isReconnecting = NO;
    _isSending = NO;
    _isConnected = NO;
}

-(void)setDelegate:(id<KBStreamSocketDelegate>)delegate{
    _delegate = delegate;
}

-(NSInteger)RTMP264_Connect:(char *)push_url{
    if (_isConnecting) {
        return -1;
    }
    _isConnecting = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:KBLivePending];
    }
    if (_rtmp != NULL) {
        PILI_RTMP_Close(_rtmp,&_error);
        PILI_RTMP_Free(_rtmp);
    }
    _rtmp = PILI_RTMP_Alloc();
    PILI_RTMP_Init(_rtmp);
    
    //设置URL
    if (PILI_RTMP_SetupURL(_rtmp, push_url, &_error) < 0){
        //log(LOG_ERR, "RTMP_SetupURL() failed!");
        goto Failed;
    }
    //设置可写，即发布流，这个函数必须在连接前使用，否则无效
    PILI_RTMP_EnableWrite(_rtmp);
    
    //连接服务器
    if (PILI_RTMP_Connect(_rtmp, NULL, &_error) < 0){
        goto Failed;
    }
    
    //连接流
    if (PILI_RTMP_ConnectStream(_rtmp, 0, &_error) < 0) {
        goto Failed;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:KBLiveStart];
    }
    _isConnected = YES;
    _isConnecting = NO;
    _isReconnecting = NO;
    _isSending = NO;
    
    return 0;
Failed:
    PILI_RTMP_Close(_rtmp, &_error);
    PILI_RTMP_Free(_rtmp);
    [self clean];
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]) {
        [self.delegate socketStatus:self status:KBLiveError];
    }
    return -1;
}

#pragma mark - setters and getters
-(dispatch_queue_t)socketQueue{
    if (_socketQueue == nil) {
        _socketQueue = dispatch_queue_create("com.3glasses.vrshow.live.socketQueue", NULL);
    }
    return _socketQueue;
}

@end
