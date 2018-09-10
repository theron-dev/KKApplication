//
//  KKPortraitNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2018/7/2.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKPortraitNavigationController.h"

@interface KKPortraitNavigationController (){
   
}

@end

@implementation KKPortraitNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
