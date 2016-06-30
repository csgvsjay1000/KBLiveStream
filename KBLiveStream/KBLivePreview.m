//
//  KBLivePreview.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBLivePreview.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "KBLiveKit.h"

@interface KBLivePreview ()

@property(nonatomic,strong)UIView *containerView;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startLiveButton;

@property(nonatomic,strong)KBLiveSession *session;

@end

@implementation KBLivePreview

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor blackColor];
        [self requestAccessForVideo];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.startLiveButton];

    }
    return self;
}

#pragma mark - public methods
-(void)requestAccessForVideo{
    __weak typeof (self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            //许可没有对话出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    //如果授权许可
                    [_self.session setRunning:YES];
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已经开启授权
            NSLog(@"已经开启授权");
            [_self.session setRunning:YES];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:{
            //用户拒绝，或相机设备无法访问
            NSLog(@"用户拒绝，或相机设备无法访问");
            break;
        }
            
        default:
            break;
    }
    
    
}

#pragma mark - setters and getters
- (UIView*)containerView{
    if(!_containerView){
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (UIButton*)closeButton{
    if(!_closeButton){
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = 20;
        [_closeButton setImage:[UIImage imageNamed:@"close_preview"] forState:UIControlStateNormal];
        _closeButton.exclusiveTouch = YES;
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            
        }];
    }
    return _closeButton;
}

- (UIButton*)cameraButton{
    if(!_cameraButton){
        _cameraButton = [UIButton new];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_cameraButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
//            AVCaptureDevicePosition devicePositon = _self.session.captureDevicePosition;
//            _self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        }];
    }
    return _cameraButton;
}

- (UIButton*)startLiveButton{
    if(!_startLiveButton){
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.width - 60, 44);
        _startLiveButton.left = 30;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        __weak typeof(self) _self = self;
        [_startLiveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.startLiveButton.selected = !_self.startLiveButton.selected;
            if(_self.startLiveButton.selected){
                [_self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
                KBLiveStreamInfo *stream = [[KBLiveStreamInfo alloc] init];
                stream.url = @"rtmp://0fwc91.publish.z1.pili.qiniup.com/shutong/test1?key=0afbffdf";
                //stream.url = @"rtmp://daniulive.com:1935/live/stream2399";
                [_self.session startLive:stream];
            }else{
                [_self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
                [_self.session stopLive];
            }
        }];
    }
    return _startLiveButton;
}

-(KBLiveSession *)session{
    if (_session == nil) {
        _session = [[KBLiveSession alloc] initWithVideoConfig:[KBLiveVideoConfig defaultConfiguration]];
        _session.preView = self;
    }
    return _session;
}


@end
