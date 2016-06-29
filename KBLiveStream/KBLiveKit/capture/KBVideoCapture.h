//
//  KBVideoCapture.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBLiveVideoConfig.h"

@class KBVideoCapture;
@protocol KBVideoCaptureDelegate <NSObject>

- (void)captureOutput:(KBVideoCapture *)capture pixelBuffer:(CVImageBufferRef)pixelBuffer;

@end

@interface KBVideoCapture : NSObject

@property(nonatomic,weak)id<KBVideoCaptureDelegate> delegate;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

/** The preView will show OpenGL ES view*/
@property (nonatomic, strong) UIView * preView;

@property (nonatomic, assign) BOOL beautyFace;

-(id)initWithVideoConfig:(KBLiveVideoConfig *)configuration;

@end
