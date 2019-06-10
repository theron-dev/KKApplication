//
//  KKLandscapeNavigationController.m
//  KKApplication
//
//  Created by zhanghailong on 2018/6/22.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKLandscapeNavigationController.h"
#import <KKObserver/KKObserver.h>
#import <KKView/KKView.h>

@interface KKLandscapeNavigationController (){
    BOOL _showing;
}

@end

@implementation KKLandscapeNavigationController

-(instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_OrientationChangeAction) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}

-(void) _OrientationChangeAction {
    [self.topViewController viewDidLayoutSubviews];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

-(BOOL) prefersStatusBarHidden {
    id v = [self.action kk_getValue:@"fullScreen"];
    return v == nil || KKBooleanValue(v);
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    id v = [self.action kk_getString:@"style"];
    if(v != nil) {
        if([@"light" isEqualToString:v]) {
            return UIStatusBarStyleLightContent;
        }
    }
    return UIStatusBarStyleDefault;
}

-(UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
    return  UIStatusBarAnimationSlide;
}


@end
