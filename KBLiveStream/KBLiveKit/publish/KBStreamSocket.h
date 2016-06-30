//
//  KBStreamSocket.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/30/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBLiveStreamInfo.h"
#import "KBFrame.h"

@protocol KBStreamSocket;

@protocol KBStreamSocketDelegate <NSObject>

//-(void)socketBufferStatus

-(void)socketStatus:(id<KBStreamSocket>)socket status:(KBLiveState)status;

@end

@protocol KBStreamSocket <NSObject>

-(id)initWithStream:(KBLiveStreamInfo *)stream;
-(void)setDelegate:(id<KBStreamSocketDelegate>)delegate;
-(void)start;
-(void)stop;
-(void)sendFrame:(KBFrame *)frame;

@end
