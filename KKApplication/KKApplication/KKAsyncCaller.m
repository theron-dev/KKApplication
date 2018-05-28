//
//  KKAsyncCaller.m
//  KKApplication
//
//  Created by hailong11 on 2018/5/11.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "KKAsyncCaller.h"

@interface KKAsyncCaller() {
    int _id;
    NSMutableDictionary * _timers;
}

-(NSString *) newKey;

-(void) setTimer:(NSTimer *) timer key:(NSString *) key;

-(void) removeTimer:(NSString *) key;

@end

@implementation KKAsyncCaller

@synthesize SetTimeoutFunc = _SetTimeoutFunc;
@synthesize ClearTimeoutFunc = _ClearTimeoutFunc;
@synthesize SetIntervalFunc = _SetIntervalFunc;
@synthesize ClearIntervalFunc = _ClearIntervalFunc;

-(instancetype) init {
    
    if((self = [super init])) {
        
        _timers = [[NSMutableDictionary alloc] initWithCapacity:4];
        
        __weak KKAsyncCaller * v = self;
        
        _SetTimeoutFunc = ^NSString*() {
            if(v) {
                NSArray * arguments = [JSContext currentArguments];
                JSValue * fn = [arguments count] > 0 ? arguments[0] : nil;
                if(fn && [fn isObject]) {
                    NSString * key = [v newKey];
                    NSTimeInterval tv = [arguments count] > 1? [(JSValue *) arguments[1] toUInt32] * 0.001 : 0;
                    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:tv
                                                                       target:v
                                                                     selector:@selector(doAction:)
                                                                     userInfo:@{
                                                                                @"fn" : fn,
                                                                                @"free" : @(true),
                                                                                @"key":key }
                                                                      repeats:NO];
                    [v setTimer:timer key:key];
                    return key;
                }
            }
            return nil;
        };
        
        _ClearTimeoutFunc = ^() {
            if(v) {
                NSArray * arguments = [JSContext currentArguments];
                NSString * key = [arguments count] > 0 ? [arguments[0] toString] : nil;
                if(key) {
                    [v removeTimer:key];
                }
            }
        };
        
        _SetIntervalFunc = ^NSString*() {
            if(v) {
                NSArray * arguments = [JSContext currentArguments];
                JSValue * fn = [arguments count] > 0 ? arguments[0] : nil;
                if(fn && [fn isObject]) {
                    NSString * key = [v newKey];
                    NSTimeInterval tv = [arguments count] > 1? [(JSValue *) arguments[1] toUInt32] * 0.001 : 0;
                    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:tv
                                                                       target:v
                                                                     selector:@selector(doAction:)
                                                                     userInfo:@{
                                                                                @"fn" : fn,
                                                                                @"free" : @(false),
                                                                                @"key":key }
                                                                      repeats:YES];
                    [v setTimer:timer key:key];
                    return key;
                }
            }
            return nil;
        };
        
        _ClearIntervalFunc = ^() {
            if(v) {
                NSArray * arguments = [JSContext currentArguments];
                NSString * key = [arguments count] > 0 ? [arguments[0] toString] : nil;
                if(key) {
                    [v removeTimer:key];
                }
            }
        };
        
    }
    
    return self;
}

-(void) doAction:(NSTimer *) timer {
    
    NSString * key = [timer.userInfo valueForKey:@"key"];
    JSValue * fn = [timer.userInfo valueForKey:@"fn"];
    BOOL isFree = [[timer.userInfo valueForKey:@"free"] boolValue];
    
    @try{
        [fn callWithArguments:@[]];
    }
    @catch(NSException * ex) {
        NSLog(@"[KK] %@",ex);
    }
    
    if(isFree) {
        [timer invalidate];
        [_timers removeObjectForKey:key];
    }
}

-(void) setTimer:(NSTimer *) timer key:(NSString *) key {
    [_timers setValue:timer forKey:key];
}

-(void) removeTimer:(NSString *) key {
    if(key == nil) {
        return;
    }
    NSTimer * v = [_timers valueForKey:key];
    if(v) {
        [v invalidate];
        [_timers removeObjectForKey:key];
    }
}

-(NSString *) newKey {
    return [NSString stringWithFormat:@"%d", ++ _id];
}

-(void) dealloc {
    [self recycle];
}

-(void) recycle {
    for(NSTimer * timer in [_timers allValues]) {
        [timer invalidate];
    }
    _timers = nil;
}

@end
