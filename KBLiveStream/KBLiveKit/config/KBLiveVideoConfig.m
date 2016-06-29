//
//  KBLiveVideoConfig.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBLiveVideoConfig.h"
#import <AVFoundation/AVFoundation.h>

@implementation KBLiveVideoConfig

#pragma mark - life cycle
+(instancetype)defaultConfiguration{
    KBLiveVideoConfig *config = [KBLiveVideoConfig defaultConfigurationForQuality:KBLiveVideoQuality_Default];
    return config;
}

+(instancetype)defaultConfigurationForQuality:(KBLiveVideoQuality)videoQuality{
    KBLiveVideoConfig *config = [KBLiveVideoConfig defaultConfigurationForQuality:videoQuality orientation:UIInterfaceOrientationPortrait];
    return config;
}

+(instancetype)defaultConfigurationForQuality:(KBLiveVideoQuality)videoQuality orientation:(UIInterfaceOrientation)orientation{
    KBLiveVideoConfig *configuration = [[KBLiveVideoConfig alloc] init];
    
    switch (videoQuality) {
        case KBLiveVideoQuality_Low1:{
            
        }
            break;
        case KBLiveVideoQuality_Low2:{
            configuration.sessionPreset = KBLiveVideoSessionPreset360x640;
            configuration.videoFrameRate = 24;
            configuration.videoMaxFrameRate = 24;
            configuration.videoMinFrameRate = 12;
            configuration.videoBitRate = 800 * 1024;
            configuration.videoMaxBitRate = 900 * 1024;
            configuration.videoMinBitRate = 500 * 1024;
        }
            break;
            
        default:
            break;
    }
    configuration.sessionPreset = [configuration supportSessionPreset:configuration.sessionPreset];
    configuration.videoMaxKeyframeInterval = configuration.videoFrameRate*2;
    configuration.orientation = orientation;
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        configuration.videoSize = CGSizeMake(368, 640);
    }else{
        configuration.videoSize = CGSizeMake(640, 368);
    }
    
    return configuration;
}

#pragma mark - private methods
-(KBLiveVideoSessionPreset)supportSessionPreset:(KBLiveVideoSessionPreset)sessionPreset{
    NSString *avSessionPreset = [self avSessionPreset];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if (![session canSetSessionPreset:avSessionPreset]) {
        NSLog(@"不支持 sessionPreset %d",sessionPreset);
    }else{
        NSLog(@"支持 sessionPreset %d",sessionPreset);
    }
    return sessionPreset;
}

#pragma mark - setters and getters
-(NSString *)avSessionPreset{
    NSString *avSessionPreset = nil;
    switch (self.sessionPreset) {
        case KBLiveVideoSessionPreset360x640:
            avSessionPreset = AVCaptureSessionPreset640x480;
            break;
            
        default:
            break;
    }
    return avSessionPreset;
}

@end
