//
//  KKPageViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKPageViewController.h"
#import <KKHttp/KKHttp.h>

@interface KKPageViewController ()

@end

@implementation KKPageViewController

+(Class) controllerClass {
    return [KKPageController class];
}

-(KKPageController *) pageController {
    return (KKPageController *) self.controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.pageController layout:self];
}

-(void) dealloc {
    NSLog(@"KKPageViewController dealloc");
}

@end
