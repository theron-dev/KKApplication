//
//  KKLandscapeNavigationController.m
//  KKApplication
//
//  Created by hailong11 on 2018/6/22.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKLandscapeNavigationController.h"

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


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

@end
