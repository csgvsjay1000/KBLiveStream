//
//  KBStreamRtmpSocket.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/30/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBStreamRtmpSocket.h"
#import "rtmp.h"


#define SAVC(x)    static const AVal av_##x = AVC(#x)

static const AVal av_setDataFrame = AVC("@setDataFrame");
static const AVal av_SDKVersion = AVC("LFLiveKit 1.5.2");

SAVC(onMetaData);
SAVC(duration);
SAVC(width);
SAVC(height);
SAVC(videocodecid);
SAVC(videodatarate);
SAVC(framerate);
SAVC(audiocodecid);
SAVC(audiodatarate);
SAVC(audiosamplerate);
SAVC(audiosamplesize);
SAVC(audiochannels);
SAVC(stereo);
SAVC(encoder);
SAVC(av_stereo);
SAVC(fileSize);
SAVC(avc1);
SAVC(mp4a);

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
    
    [self sendMetaData];
    
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

#pragma mark - Rtmp send
-(void)sendMetaData{
    
//    while (1) {
//        sleep(1);
        PILI_RTMPPacket packet;
        char pbuf[2048], *pend = pbuf+sizeof(pbuf);
        
        NSLog(@"sizeof(pbuf) %ld",sizeof(pbuf));
        packet.m_nChannel = 0x03;     // control channel (invoke)
        packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
        packet.m_packetType = RTMP_PACKET_TYPE_INFO;
        packet.m_nTimeStamp = 0;
        packet.m_nInfoField2 = _rtmp->m_stream_id;
        packet.m_hasAbsTimestamp = TRUE;
        packet.m_body = pbuf + RTMP_MAX_HEADER_SIZE;
        
        char *enc = packet.m_body;
        enc = AMF_EncodeString(enc, pend, &av_setDataFrame);
        enc = AMF_EncodeString(enc, pend, &av_onMetaData);
        
        *enc++ = AMF_OBJECT;
        
        enc = AMF_EncodeNamedNumber(enc, pend, &av_duration,        0.0);
        enc = AMF_EncodeNamedNumber(enc, pend, &av_fileSize,        0.0);
        
        // videosize
        enc = AMF_EncodeNamedNumber(enc, pend, &av_width,           _stream.videoConfiguration.videoSize.width);
        enc = AMF_EncodeNamedNumber(enc, pend, &av_height,          _stream.videoConfiguration.videoSize.height);
        
        // video
        enc = AMF_EncodeNamedString(enc, pend, &av_videocodecid,    &av_avc1);
        
        enc = AMF_EncodeNamedNumber(enc, pend, &av_videodatarate,   _stream.videoConfiguration.videoBitRate / 1000.f);
        enc = AMF_EncodeNamedNumber(enc, pend, &av_framerate,       _stream.videoConfiguration.videoFrameRate);
        
//        // audio
//        enc = AMF_EncodeNamedString(enc, pend, &av_audiocodecid,    &av_mp4a);
//        enc = AMF_EncodeNamedNumber(enc, pend, &av_audiodatarate,   _stream.audioConfiguration.audioBitrate);
//        
//        enc = AMF_EncodeNamedNumber(enc, pend, &av_audiosamplerate, _stream.audioConfiguration.audioSampleRate);
//        enc = AMF_EncodeNamedNumber(enc, pend, &av_audiosamplesize, 16.0);
//        enc = AMF_EncodeNamedBoolean(enc, pend, &av_stereo,     _stream.audioConfiguration.numberOfChannels==2);
        
        // sdk version
        enc = AMF_EncodeNamedString(enc, pend, &av_encoder,         &av_SDKVersion);
        
        *enc++ = 0;
        *enc++ = 0;
        *enc++ = AMF_OBJECT_END;
        
        packet.m_nBodySize = enc - packet.m_body;
   
        if(!PILI_RTMP_SendPacket(_rtmp, &packet, FALSE, &_error)) {
            NSLog(@"PILI_RTMP_SendPacket error :%s",_error.message);
            return;
        }
        NSLog(@"PILI_RTMP_SendPacketed");
//    }
    
    
}

-(void)sendFrame:(KBFrame *)frame{
    __weak typeof(self) _self = self;
    dispatch_async(self.socketQueue, ^{
        __strong typeof(_self) self = _self;
        if(!frame) return;
//        [self.buffer appendObject:frame];
//        [self sendFrame];
    });
}

#pragma mark - setters and getters
-(dispatch_queue_t)socketQueue{
    if (_socketQueue == nil) {
        _socketQueue = dispatch_queue_create("com.3glasses.vrshow.live.socketQueue", NULL);
    }
    return _socketQueue;
}

@end
