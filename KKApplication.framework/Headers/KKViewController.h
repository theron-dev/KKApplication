//
//  KKViewController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKApplication/KKApp.h>
#import <KKHttp/KKHttp.h>
#import <KKApplication/KKController.h>

@interface KKViewController : UIViewController<KKViewController>

@property(nonatomic,strong,readonly) KKController * controller;
@property(nonatomic,assign,readonly,getter=isNextViewController) BOOL nextViewController;

-(IBAction) doCloseAction:(id)sender;

+(Class) controllerClass;

@end
