//
//  KKObserver.h
//  KKObserver
//
//  Created by 张海龙 on 2017/12/4.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <KKObserver/KKJSObserver.h>

#define KKOBSERVER_PRIORITY_ASC -1
#define KKOBSERVER_PRIORITY_LOW INT32_MIN
#define KKOBSERVER_PRIORITY_NORMAL 0
#define KKOBSERVER_PRIORITY_HIGH INT32_MAX
#define KKOBSERVER_PRIORITY_DESC 1

typedef void (^KKObserverFunction)(id value,NSArray * changedKeys,void * context);


@interface KKObserver : NSObject {
    
}

@property(nonatomic,strong) NSMutableDictionary * object;
@property(nonatomic,weak) KKObserver * parent;
@property(nonatomic,strong,readonly) JSContext *jsContext;

-(instancetype) initWithJSContext:(JSContext *) jsContext;
-(instancetype) initWithJSContext:(JSContext *) jsContext object:(NSMutableDictionary *) object;
-(instancetype) init;
-(instancetype) initWithObject:(id) object;

-(void) changeKeys:(NSArray *) keys;

-(id) get:(NSArray *) keys defaultValue:(id) defaultValue;

-(void) set:(NSArray *) keys value:(id) value;

-(void) on:(KKObserverFunction) func evaluateScript:(NSString *) evaluateScript priority:(NSInteger) priority context:(void *) context;

-(void) on:(KKObserverFunction) func evaluateScript:(NSString *) evaluateScript context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys children:(BOOL) children context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys children:(BOOL) children priority:(NSInteger) priority context:(void *) context;

-(void) on:(KKObserverFunction) func keys:(NSArray *) keys context:(void *) context;

-(void) off:(KKObserverFunction) func keys:(NSArray *) keys context:(void *) context;

-(void) on:(NSArray *) keys fn:(JSValue *) func context:(void *) context;

-(void) onEvaluateScript:(NSString *) evaluateScript fn:(JSValue *) func  context:(void *) context;

-(void) off:(NSArray *) keys fn:(JSValue *) func context:(void *) context ;

-(id) evaluateScript:(NSString*) evaluateScript;

-(instancetype) newObserver;

+(JSContext *) mainJSContext;

+(void) setMainJSContext:(JSContext *) mainJSContext;

@end

@interface NSObject(KKObserver)

-(id) kk_getValue:(NSString *) key;

-(void) kk_setValue:(NSString *) key value:(id) value;

-(id) kk_get:(NSArray *) keys defaultValue:(id) defaultValue;

-(void) kk_set:(NSArray *) keys value:(id) value;

-(NSSet *) kk_keySet;

-(NSString *) kk_stringValue;

-(NSString *) kk_getString:(NSString *) key;

@end


