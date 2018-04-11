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
    if(self.topViewController == nil) {
        return [super shouldAutorotate];
    }
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(self.topViewController == nil) {
        return [super supportedInterfaceOrientations];
    }
    return [self.topViewController supportedInterfaceOrientations];
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    if(self.topViewController == nil) {
        return [super preferredInterfaceOrientationForPresentation];
    }
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    [UIViewController attemptRotationToDeviceOrientation];
}

-(UIViewController *) popViewControllerAnimated:(BOOL)animated {
    UIViewController * v = [super popViewControllerAnimated:animated];
    [UIViewController attemptRotationToDeviceOrientation];
    return v;
}

@end
