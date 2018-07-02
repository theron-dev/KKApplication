//
//  KKLandscapeNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2018/6/22.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKLandscapeNavigationController.h"
#import <KKObserver/KKObserver.h>
#import <KKView/KKView.h>

@interface KKLandscapeNavigationController ()

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
/*
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    {
        id v = [self.action kk_getValue:@"fullScreen"];
        
        if(v == nil || KKBooleanValue(v)) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }
    
    {
        id v = [self.action kk_getString:@"style"];
        if(v != nil) {
            if([@"light" isEqualToString:v]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
        }
    }
    
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    {
        id v = [self.action kk_getValue:@"fullScreen"];
        
        if(v == nil || KKBooleanValue(v)) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
    }
    
    {
        id v = [self.action kk_getString:@"style"];
        if(v != nil) {
            if([@"light" isEqualToString:v]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
        }
    }
    
}
*/

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
