//
//  KKNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKNavigationController.h"

@interface KKNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation KKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
