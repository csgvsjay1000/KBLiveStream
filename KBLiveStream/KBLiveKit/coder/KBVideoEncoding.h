//
//  KBVideoEncoding.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBLiveVideoConfig.h"
#import "KBVideoFrame.h"

@protocol KBVideoEncoding;

@protocol KBVideoEncodingDelegate <NSObject>

-(void)videoEncoder:(id<KBVideoEncoding>)encoder videoFrame:(KBVideoFrame *)frame;

@end

@protocol KBVideoEncoding <NSObject>

-(id)initWithVideoStreamConfig:(KBLiveVideoConfig *)configuration;

-(void)encodeVideoData:(CVImageBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

- (void)stopEncoder;

-(void)setDelegate:(id<KBVideoEncodingDelegate>)delegate;

@end
