//
//  KBLiveVideoConfig.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    //分辨率  360*640  帧数 15 码率 500Kps
    KBLiveVideoQuality_Low1 = 0,
    // 分辨率： 360 *640 帧数：24 码率：800Kps
    KBLiveVideoQuality_Low2 = 1,
    // 默认配置
    KBLiveVideoQuality_Default = KBLiveVideoQuality_Low2,
}KBLiveVideoQuality;

/// 视频分辨率(都是16：9 当此设备不支持当前分辨率，自动降低一级)
typedef enum {
    /// 低分辨率
    KBLiveVideoSessionPreset360x640 = 0,
    /// 中分辨率
    KBLiveVideoSessionPreset540x960 = 0,
    /// 高分辨率
    KBLiveVideoSessionPreset720x1280 = 0,

}KBLiveVideoSessionPreset;

@interface KBLiveVideoConfig : NSObject

+(instancetype)defaultConfiguration;

/**
    Attribute
 */

@property(nonatomic,assign)CGSize videoSize;
@property(nonatomic,assign)UIInterfaceOrientation orientation;
@property (nonatomic, assign) NSUInteger videoFrameRate;
@property (nonatomic, assign) NSUInteger videoMaxFrameRate;
@property (nonatomic, assign) NSUInteger videoMinFrameRate;
/// 最大关键帧间隔，可设定为 fps 的2倍，影响一个 gop 的大小
@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;
/// 视频的码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoBitRate;
/// 视频的最大码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMaxBitRate;

/// 视频的最小码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMinBitRate;

//分辨率
@property(nonatomic,assign)KBLiveVideoSessionPreset sessionPreset;

@property (nonatomic, assign,readonly) NSString *avSessionPreset;
///< 是否裁剪
@property (nonatomic, assign,readonly) BOOL isClipVideo;

@end
