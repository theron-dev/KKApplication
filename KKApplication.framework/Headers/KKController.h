//
//  KKController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKApplication/KKApp.h>
#import <KKHttp/KKHttp.h>

@interface KKController : NSObject

@property(nonatomic,strong) KKApplication * application;
@property(nonatomic,strong,readonly) KKObserver * observer;
@property(nonatomic,strong,readonly) KKJSHttp * http;
@property(nonatomic,strong) NSDictionary * query;
@property(nonatomic,strong) NSString * path;

-(IBAction) doTopbarRightAction:(id)sender;
-(IBAction) doTopbarLeftAction:(id)sender;

-(void) run;

-(void) run:(UIViewController *) viewController;

-(void) willAppear;
-(void) didAppear;
-(void) willDisappear;
-(void) didDisappear;

@end
