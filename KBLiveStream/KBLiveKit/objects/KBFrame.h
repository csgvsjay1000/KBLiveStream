//
//  KBFrame.h
//  KBLiveStream
//
//  Created by chengshenggen on 6/29/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBFrame : NSObject

@property(nonatomic,assign)uint64_t timestamp;
@property(nonatomic,strong)NSData *data;

/// flv或rtmp包头
@property(nonatomic,strong)NSData *header;

@end
