//
//  KKEvent.h
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKEvent : NSObject

@end

typedef void (^KKEventEmitterFunction) (KKEvent * event,void * context);

@interface KKEventEmitter : NSObject

-(void) on:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context;

-(void) off:(NSString *) name fn:(KKEventEmitterFunction) fn context:(void *) context;

-(void) emit:(NSString *) name event:(KKEvent *) event;

@end

