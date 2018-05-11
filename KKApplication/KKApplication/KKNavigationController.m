//
//  KKNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKNavigationController.h"
#import "KKController.h"

@interface UINavigationController(KKNavigationController) <UINavigationBarDelegate,UIGestureRecognizerDelegate>

@end

@interface KKNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation KKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if( [[self topViewController] kk_navigationShouldPopViewController]) {
        if([super respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            @try {
                return [super navigationBar:navigationBar shouldPopItem:item];
            } @catch(NSException * ex) {}
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if( ![[self topViewController] kk_navigationShouldPopViewController]) {
            return NO;
        }
    }
    return YES;
}

@end
