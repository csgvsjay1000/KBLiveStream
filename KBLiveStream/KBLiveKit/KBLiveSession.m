//
//  KBLiveSession.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBLiveSession.h"
#import "KBVideoCapture.h"
#import "KBHardwareVideoEncoder.h"
#import "KBStreamRtmpSocket.h"
#import "KBLiveStreamInfo.h"

@interface KBLiveSession ()<KBVideoCaptureDelegate,KBVideoEncodingDelegate,KBStreamSocketDelegate>{
    dispatch_semaphore_t _lock;
}

/// 视频采集
@property(nonatomic,strong)KBVideoCapture *videoCaptureSource;
///视频配置
@property(nonatomic,strong)KBLiveVideoConfig *videoConfiguration;
/// 视频编码
@property(nonatomic,strong)id<KBVideoEncoding> videoEncoder;
/// 上传
@property(nonatomic,strong)id<KBStreamSocket> socket;

/// uploading
@property (nonatomic, assign) BOOL uploading;
@property(nonatomic,strong)KBLiveStreamInfo *streamInfo;

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)
@property (nonatomic, assign) uint64_t timestamp;
@property (nonatomic, assign) BOOL isFirstFrame;
@property (nonatomic, assign) uint64_t currentTimestamp;

@end

@implementation KBLiveSession

-(instancetype)initWithVideoConfig:(KBLiveVideoConfig *)videoConfiguration{
    if (self = [super init]) {
        _videoConfiguration = videoConfiguration;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - start live
-(void)startLive:(KBLiveStreamInfo *)streamInfo{
    if (streamInfo == nil) {
        return;
    }
    _streamInfo = streamInfo;
    _streamInfo.videoConfiguration = _videoConfiguration;
    [self.socket start];
}

-(void)stopLive{
    
}

#pragma mark - CaptureDelegate
- (void)captureOutput:(KBVideoCapture *)capture pixelBuffer:(CVImageBufferRef)pixelBuffer{
    [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:self.currentTimestamp];
}

#pragma mark - EncoderDelegate
-(void)videoEncoder:(id<KBVideoEncoding>)encoder videoFrame:(KBVideoFrame *)frame{
    
}

#pragma mark - KBStreamSocketDelegate
-(void)socketStatus:(id<KBStreamSocket>)socket status:(KBLiveState)status{
    switch (status) {
        case KBLivePending:
            NSLog(@"正在连接...");
            break;
        case KBLiveStart:
            NSLog(@"已连接");
            break;
        case KBLiveError:
            NSLog(@"连接出错");
            break;
            
        default:
            break;
    }
}

#pragma mark - setters and getters
-(void)setRunning:(BOOL)running{
    if (_running == running) {
        return;
    }
    [self willChangeValueForKey:@"running"];
    _running = running;
    [self didChangeValueForKey:@"running"];
    self.videoCaptureSource.running = _running;
    
}

-(void)setPreView:(UIView *)preView{
    [self.videoCaptureSource setPreView:preView];
}

-(KBVideoCapture *)videoCaptureSource{
    if(!_videoCaptureSource){
        _videoCaptureSource = [[KBVideoCapture alloc] initWithVideoConfig:_videoConfiguration];
        _videoCaptureSource.delegate = self;
    }
    return _videoCaptureSource;
}

-(id<KBVideoEncoding>)videoEncoder{
    if (_videoEncoder == nil) {
        _videoEncoder = [[KBHardwareVideoEncoder alloc] initWithVideoStreamConfig:_videoConfiguration];
        [_videoEncoder setDelegate:self];
    }
    return _videoEncoder;
}

-(uint64_t)currentTimestamp{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    uint64_t currentts = 0;
    if (_isFirstFrame == true) {
        _timestamp = NOW;
        _isFirstFrame = false;
        currentts = 0;
    }else{
        currentts = NOW - _timestamp;
    }
    dispatch_semaphore_signal(_lock);
    return currentts;
}

-(id<KBStreamSocket>)socket{
    if (_socket == nil) {
        _socket = [[KBStreamRtmpSocket alloc] initWithStream:_streamInfo];
        [_socket setDelegate:self];
    }
    return _socket;
}

@end
