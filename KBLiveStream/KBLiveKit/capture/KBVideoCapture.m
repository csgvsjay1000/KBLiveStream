//
//  KBVideoCapture.m
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBVideoCapture.h"
#import "GPUImage.h"
#import "LFGPUImageEmptyFilter.h"

@interface KBVideoCapture ()

@property(nonatomic,strong)GPUImageVideoCamera *videoCamera;
@property(nonatomic,strong)KBLiveVideoConfig *configuration;
@property(nonatomic, strong) GPUImageView *gpuImageView;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *emptyFilter;

@end

@implementation KBVideoCapture

#pragma mark - life cycle
-(id)initWithVideoConfig:(KBLiveVideoConfig *)configuration{
    if (self = [super init]) {
        _configuration = configuration;
        
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_configuration.avSessionPreset cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = _configuration.orientation;
        _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
        _videoCamera.horizontallyMirrorRearFacingCamera = NO;
        _videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
        
        _gpuImageView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        [_gpuImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_gpuImageView setInputRotation:kGPUImageFlipHorizonal atIndex:0];
        
        self.beautyFace = YES;
    }
    return self;
}

- (void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_videoCamera stopCameraCapture];
}

#pragma mark -- Custom Method
- (void)processVideo:(GPUImageOutput *)output{
    __weak typeof(self) _self = self;
    @autoreleasepool {
        GPUImageFramebuffer *imageFramebuffer = output.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFramebuffer pixelBuffer];
        
        if(pixelBuffer && _self.delegate && [_self.delegate respondsToSelector:@selector(captureOutput:pixelBuffer:)]){
            [_self.delegate captureOutput:_self pixelBuffer:pixelBuffer];
        }
        
    }
}


#pragma mark - setters and getters
-(void)setRunning:(BOOL)running{
    if(_running == running) return;
    _running = running;
    
    if(!_running){
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [_videoCamera stopCameraCapture];
    }else{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [_videoCamera startCameraCapture];
    }
    
}

- (void)setPreView:(UIView *)preView{
    if(_gpuImageView.superview) [_gpuImageView removeFromSuperview];
    [preView insertSubview:_gpuImageView atIndex:0];
}

- (UIView*)preView{
    return _gpuImageView.superview;
}

- (void)setBeautyFace:(BOOL)beautyFace{
    if(_beautyFace == beautyFace) return;
    
    _beautyFace = beautyFace;
    [_filter removeAllTargets];
    
    _filter = [[LFGPUImageEmptyFilter alloc] init];
    __weak typeof(self) _self = self;
    [_filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [_self processVideo:output];
    }];
    
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_gpuImageView];
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        [_gpuImageView setInputRotation:kGPUImageFlipHorizonal atIndex:0];
    } else {
        [_gpuImageView setInputRotation:kGPUImageNoRotation atIndex:0];
    }
    
}

@end
