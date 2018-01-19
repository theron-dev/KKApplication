//
//  KKApp.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <KKObserver/KKObserver.h>
#import <KKView/KKView.h>

#define KKApplicationKernel 1.0

@class KKWindowPageController;
@class KKApplication;

@protocol KKViewController

@property(nonatomic,strong) NSDictionary * action;
@property(nonatomic,strong) KKApplication * application;

@optional
-(UIView *) contentView;

@end

@protocol KKApplicationDelegate

@optional

-(BOOL) KKApplication:(KKApplication *) application openViewController:(UIViewController *) viewController;

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
@property(nonatomic,strong,readonly) KKViewContext * viewContext;
@property(nonatomic,strong,readonly) NSBundle * bundle;
@property(nonatomic,strong,readonly) NSString * path;

-(instancetype) initWithBundle:(NSBundle *) bundle;

-(instancetype) initWithBundle:(NSBundle *) bundle jsContext:(JSContext *) jsContext;

-(KKElement *) elementWithPath:(NSString *) path observer:(KKObserver *) observer;

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

+(UIViewController *) topViewController:(UIViewController *) viewController ;

+(instancetype) main;

@end

@interface UIApplication (KKApplication)

@property(nonatomic,strong,readonly) KKApplication * KKApplication;
@property(nonatomic,strong,readonly) UIViewController * kk_topViewController;

@end

