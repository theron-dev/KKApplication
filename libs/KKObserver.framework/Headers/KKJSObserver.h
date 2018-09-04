//
//  KKJSObserver.h
//  KKObserver
//
//  Created by zhanghailong on 2018/3/28.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class KKObserver;

@protocol KKJSObserver<JSExport>

JSExportAs(changeKeys,
           -(void) changeKeys:(NSArray *) keys
           );

JSExportAs(get,
           -(id) get:(NSArray *) keys defaultValue:(id) defaultValue
           );

JSExportAs(set,
           -(void) set:(NSArray *) keys value:(id) value
           );

JSExportAs(on,
           -(void) on:(NSArray *) keys fn:(JSValue *) func
           );

JSExportAs(evaluate,
           -(void) onEvaluateScript:(NSString *) evaluateScript fn:(JSValue *) func
           );

JSExportAs(off,
           -(void) off:(NSArray *) keys fn:(JSValue *) func 
           );

JSExportAs(evaluateScript,
-(id) evaluateScript:(NSString*) evaluateScript
           );

@end

@interface KKJSObserver : NSObject<KKJSObserver>

@property(nonatomic,strong,readonly) KKObserver * observer;

-(instancetype) initWithObserver:(KKObserver *) observer;

-(void) recycle;

-(instancetype) newObserver;

@end
