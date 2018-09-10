//
//  KKPageController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <KKApplication/KKController.h>
#import <KKView/KKView.h>

@interface KKPageController : KKController

@property(nonatomic,strong,readonly) KKViewElement * element;
@property(nonatomic,strong) NSSet * elementNeedsLayoutDataKeys;
@property(nonatomic,strong) NSString * viewPath;

-(void) runInView:(UIView *) view;

-(void) layoutInView:(UIView *) view hasScreenContentEdge:(BOOL) hasScreenContentEdge;

-(void) layout:(UIViewController *) viewController;

-(void) installTopbar:(UIViewController *) viewController;

-(void) layoutTopbar:(UIViewController *) viewController;

-(void) recycle;

+(UIEdgeInsets) screenContentEdgeInsetsWithEdge:(NSString *) edge;

@end
