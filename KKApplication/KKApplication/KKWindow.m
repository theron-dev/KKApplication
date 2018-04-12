//
//  KKWindow.m
//  KKApplication
//
//  Created by hailong11 on 2018/4/12.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKWindow.h"
#import "KKViewController.h"

@implementation KKWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) _init {
    _interfaceOrientation = UIInterfaceOrientationUnknown;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewControllerWillAppert) name:KKViewControllerWillAppearNotification object:nil];
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self _init];
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self _init];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKViewControllerWillAppearNotification object:nil];
}

-(UIViewController *) topViewController {
    return [self topViewController:self.rootViewController];
}

-(UIViewController *) topViewController:(UIViewController *) viewController {
    
    if(viewController.presentingViewController) {
        return viewController.presentingViewController;
    }
    
    if([viewController isKindOfClass:[UINavigationController class]]) {
        
        if([(UINavigationController *) viewController topViewController]) {
            return [self topViewController:[(UINavigationController *) viewController topViewController]];
        }
        
        return viewController;
    }
    
    if([viewController isKindOfClass:[UITabBarController class]]) {
        
        if([(UITabBarController *) viewController selectedViewController]) {
            return [self topViewController:[(UITabBarController *) viewController selectedViewController]];
        }
        
        return viewController;
    }
    
    return viewController;
}

-(void) changeOrientation:(BOOL) animated {
    
    UIViewController * topViewController = [self topViewController];
    
    UIInterfaceOrientationMask mask = [topViewController supportedInterfaceOrientations];
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    UIInterfaceOrientation toOrientation = UIInterfaceOrientationUnknown;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            if((mask & UIInterfaceOrientationMaskLandscapeLeft)) {
                toOrientation = UIInterfaceOrientationLandscapeLeft;
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            if((mask & UIInterfaceOrientationMaskLandscapeRight)) {
                toOrientation = UIInterfaceOrientationLandscapeRight;
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            if((mask & UIInterfaceOrientationMaskPortraitUpsideDown)) {
                toOrientation = UIInterfaceOrientationPortraitUpsideDown;
            }
            break;
        default:
            if((mask & UIInterfaceOrientationMaskPortrait)) {
                toOrientation = UIInterfaceOrientationPortrait;
            }
            break;
    }
    
    if(toOrientation == UIInterfaceOrientationUnknown) {
        
        if(UIDeviceOrientationIsLandscape(deviceOrientation) && UIInterfaceOrientationIsLandscape(_interfaceOrientation)) {
            toOrientation = _interfaceOrientation;
        } else if((mask & UIInterfaceOrientationMaskPortrait)) {
            toOrientation = UIInterfaceOrientationPortrait;
        } else if((mask & UIInterfaceOrientationMaskLandscapeRight)) {
            toOrientation = UIInterfaceOrientationLandscapeRight;
        } else if((mask & UIInterfaceOrientationMaskLandscapeLeft)) {
            toOrientation = UIInterfaceOrientationLandscapeLeft;
        } else if((mask & UIInterfaceOrientationMaskPortraitUpsideDown)) {
            toOrientation = UIInterfaceOrientationPortraitUpsideDown;
        } else {
            toOrientation = UIInterfaceOrientationPortrait;
        }
        
    }
    
    
    if(_interfaceOrientation == toOrientation) {
        [[UIApplication sharedApplication] setStatusBarOrientation:toOrientation animated:NO];
        return;
    }
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(bounds.size.width,bounds.size.height);
    CGFloat height = MAX(bounds.size.width,bounds.size.height);
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
    }
    
    self.transform = CGAffineTransformIdentity;
    
    switch (toOrientation) {
        case UIInterfaceOrientationLandscapeRight:
            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.bounds = CGRectMake(0, 0, height, width);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.bounds = CGRectMake(0, 0, height, width);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.transform = CGAffineTransformMakeRotation(M_PI);
            self.bounds = CGRectMake(0, 0, width, height);
            break;
        default:
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, width, height);
            break;
    }
    
    if(animated) {
        [UIView commitAnimations];
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:toOrientation animated:animated];
    
    _interfaceOrientation = toOrientation;
    
}

-(void) _deviceOrientation {
    [self changeOrientation:YES];
}

-(void) _viewControllerWillAppert {
    [self changeOrientation:YES];
}


@end
