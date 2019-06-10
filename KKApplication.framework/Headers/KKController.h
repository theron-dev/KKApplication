//
//  KKController.h
//  KKApplication
//
//  Created by zhanghailong on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKApplication/KKApp.h>
#import <KKHttp/KKHttp.h>
#import <KKApplication/KKAsyncCaller.h>

@interface KKController : NSObject

@property(nonatomic,strong) KKApplication * application;
@property(nonatomic,strong,readonly) KKObserver * observer;
@property(nonatomic,strong,readonly) KKJSObserver * jsObserver;
@property(nonatomic,strong,readonly) KKJSObserver * jsApp;
@property(nonatomic,strong,readonly) KKJSHttp * http;
@property(nonatomic,strong,readonly) KKAsyncCaller * asyncCaller;
@property(nonatomic,strong,readonly) JSValue * jsWebSocket;
@property(nonatomic,strong) NSDictionary * query;
@property(nonatomic,strong) NSString * path;

-(void) run;

-(void) run:(UIViewController *) viewController;

-(void) willAppear;
-(void) didAppear;
-(void) willDisappear;
-(void) didDisappear;

-(void) recycle;

-(void) setTopbarStyle:(UIViewController *) viewController;

-(void) clearTopbarStyle:(UIViewController *) viewController;

@end

@interface UIViewController(KKController)

@property(nonatomic,assign) BOOL kk_topbarHidden;
@property(nonatomic,assign) UIStatusBarStyle kk_statusBarStyle;
@property(nonatomic,strong) UIImage * kk_topbarBackgroundImage;
@property(nonatomic,strong) UIColor * kk_topbarBackgroundColor;

-(BOOL) kk_navigationShouldPopViewController;
@end

