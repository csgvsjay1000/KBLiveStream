//
//  KBLiveStreamInfo.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/30/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBLiveVideoConfig.h"

///流状态
typedef enum {
    ///准备
    KBLiveReady = 0,
    /// 连接中
    KBLivePending = 1,
    /// 已连接
    KBLiveStart = 2,
    /// 已断开
    KBLiveStop = 3,
    /// 连接出错
    KBLiveError = 4
}KBLiveState;

typedef enum {
    KBLiveSocketError_PreView               = 201,///< 预览失败
    KBLiveSocketError_GetStreamInfo         = 202,///< 获取流媒体信息失败
    KBLiveSocketError_ConnectSocket         = 203,///< 连接socket失败
    KBLiveSocketError_Verification          = 204,///< 验证服务器失败
    KBLiveSocketError_ReConnectTimeOut      = 205///< 重新连接服务器超时
}KBLiveSocketErrorCode;

@interface KBLiveStreamInfo : NSObject

@property(nonatomic,copy)NSString *streamId;

// FLV
@property(nonatomic,copy)NSString *host;
@property(nonatomic,copy)NSString *port;

// RTMP
@property(nonatomic,copy)NSString *url;  //上传地址，(RTMP用就好了)

@property(nonatomic,strong)KBLiveVideoConfig *videoConfiguration;

@end
