//
//  KKAsyncCaller.h
//  KKApplication
//
//  Created by hailong11 on 2018/5/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * (^KKAsyncCallerSetTimeoutFunc)(void);
typedef void (^KKAsyncCallerClearTimeoutFunc)(void);
typedef NSString * (^KKAsyncCallerSetIntervalFunc)(void);
typedef void (^KKAsyncCallerClearIntervalFunc)(void);

@interface KKAsyncCaller : NSObject

@property(nonatomic,strong,readonly) KKAsyncCallerSetTimeoutFunc SetTimeoutFunc;
@property(nonatomic,strong,readonly) KKAsyncCallerClearTimeoutFunc ClearTimeoutFunc;
@property(nonatomic,strong,readonly) KKAsyncCallerSetIntervalFunc SetIntervalFunc;
@property(nonatomic,strong,readonly) KKAsyncCallerClearIntervalFunc ClearIntervalFunc;

-(void) recycle;

@end

