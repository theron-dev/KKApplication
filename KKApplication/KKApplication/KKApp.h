//
//  KKApp.h
//  KKApplication
//
//  Created by zhanghailong on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <KKObserver/KKObserver.h>
#import <KKView/KKView.h>
#import <KKApplication/KKAsyncCaller.h>
#import <KKWebSocket/KKWebSocket.h>

#define KKApplicationKernel 1.0

@class KKWindowPageController;
@class KKApplication;

@protocol KKObjectRecycle

-(void) recycle;

@end

@protocol KKViewController

@property(nonatomic,strong) NSDictionary * action;
@property(nonatomic,strong) KKApplication * application;

@optional
-(UIView *) contentView;

@end

@protocol KKApplicationDelegate

@optional

-(BOOL) KKApplication:(KKApplication *) application openViewController:(UIViewController *) viewController action:(NSDictionary *) action;

-(BOOL) KKApplication:(KKApplication *) application openAction:(NSDictionary *) action;

-(UIViewController *) KKApplication:(KKApplication *) application viewController:(NSDictionary *) action;

-(void) KKApplication:(KKApplication *) application willSend:(KKHttpOptions *) options ;

-(id<KKHttpTask>) KKApplication:(KKApplication *) application send:(KKHttpOptions *) options weakObject:(id) weakObject ;

-(BOOL) KKApplication:(KKApplication *) application cancel:(id) weakObject;

-(UIImage *) KKApplication:(KKApplication *) application imageWithURI:(NSString * ) uri;

@end

@interface KKApplication : NSObject<KKViewContextDelegate>

@property(nonatomic,weak) id<KKApplicationDelegate> delegate;
@property(nonatomic,strong,readonly) JSContext * jsContext;
@property(nonatomic,strong,readonly) KKObserver * observer;
@property(nonatomic,strong,readonly) KKJSObserver * jsObserver;
@property(nonatomic,strong,readonly) KKViewContext * viewContext;
@property(nonatomic,strong,readonly) NSBundle * bundle;
@property(nonatomic,strong,readonly) NSString * path;
@property(nonatomic,strong) id<KKHttp> http;
@property(nonatomic,strong) KKJSHttp * jsHttp;
@property(nonatomic,strong) JSValue * jsWebSocket;

@property(nonatomic,strong,readonly) KKAsyncCaller * asyncCaller;

-(instancetype) initWithBundle:(NSBundle *) bundle;

-(instancetype) initWithBundle:(NSBundle *) bundle jsContext:(JSContext *) jsContext;

-(KKElement *) elementWithPath:(NSString *) path data:(KKJSObserver *) data;

-(void) openlib:(NSString *) path;

-(void) exec:(NSString *) path librarys:(NSDictionary *) librarys;

-(void) doAction:(NSDictionary *) action;

-(KKObserver *) newObserver;

-(NSString *) absolutePath:(NSString *) path;

-(BOOL) has:(NSString *) path;

-(void) run;

-(UIViewController *) openViewController:(NSDictionary *) action;

-(UITabBarController *) openTabBarController:(NSDictionary *) action;

-(KKWindowPageController *) openWindowPageController:(NSDictionary *) action;

-(void) recycle;

+(UIViewController *) topViewController:(UIViewController *) viewController ;

+(JSVirtualMachine *) jsVirtualMachine;

-(void) addObjectRecycle:(id<KKObjectRecycle>) object;

-(void) removeObjectRecycle:(id<KKObjectRecycle>) object;

-(id<KKObjectRecycle>) objectRecycleForKey:(NSString *) key;

-(void) setObjectRecycle:(id<KKObjectRecycle>) object forKey:(NSString *) key;

-(void) removeObjectRecycleForKey:(NSString *) key;

@end

@interface UIApplication (KKApplication)

@property(nonatomic,strong,readonly) KKApplication * KKApplication;
@property(nonatomic,strong,readonly) UIViewController * kk_topViewController;

@end

