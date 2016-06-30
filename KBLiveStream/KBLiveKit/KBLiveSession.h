//
//  KBLiveSession.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBLiveVideoConfig.h"
#import "KBLiveStreamInfo.h"

@interface KBLiveSession : NSObject

@property(nonatomic,assign)BOOL running;
@property(nonatomic,strong)UIView *preView;


-(instancetype)init UNAVAILABLE_ATTRIBUTE;

-(instancetype)initWithVideoConfig:(KBLiveVideoConfig *)videoConfiguration;

/** The start stream .*/
- (void)startLive:(KBLiveStreamInfo*)streamInfo;

/** The stop stream .*/
- (void)stopLive;

@end
