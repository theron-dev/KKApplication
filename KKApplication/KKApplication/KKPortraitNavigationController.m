//
//  KKPortraitNavigationController.m
//  KKApplication
//
//  Created by zhanghailong on 2018/7/2.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKPortraitNavigationController.h"

@interface KKPortraitNavigationController (){
    BOOL _showing;
}

@end

@implementation KKPortraitNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.interactivePopGestureRecognizer.delegate = self;
    
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

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_showing) {
        [self.topViewController viewWillAppear:animated];
    }
    _showing = YES;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_showing) {
        [self.topViewController viewWillAppear:animated];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(_showing) {
        [self.topViewController viewWillDisappear:animated];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(_showing) {
        [self.topViewController viewDidDisappear:animated];
    }
}

@end
