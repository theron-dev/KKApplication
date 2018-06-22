//
//  KKNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKNavigationController.h"
#import "KKController.h"


@interface KKNavigationController () 

@end

@implementation KKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
