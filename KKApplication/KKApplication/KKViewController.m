//
//  KKViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKViewController.h"

NSString * const KKViewControllerWillAppearNotification = @"KKViewControllerWillAppearNotification";

@interface KKViewController () {
}

@end

@implementation KKViewController

@synthesize action = _action;
@synthesize controller = _controller;

-(KKController *) controller {
    if(_controller == nil) {
        _controller = [[[[self class] controllerClass] alloc] init];
    }
    return _controller;
}

-(void) setApplication:(KKApplication *)application {
    [self.controller setApplication:application];
}

-(KKApplication *) application {
    return [self.controller application];
}

-(void) dealloc {
    [_controller recycle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = self.view.bounds.size;
    [self.controller.observer set:@[@"page",@"landscape"] value:@(size.width > size.height)];
    
    [self.controller run:self];
    
    {
        // 关闭
        __weak KKViewController * v = self;
        [self.controller.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            [v doCloseAction:nil];
            
        } keys:@[@"action",@"close"] context:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) doCloseAction:(id)sender {
    
    if([self kk_navigationShouldPopViewController]) {
        
        if(self.navigationController) {
            
            [self.navigationController popViewControllerAnimated:YES];
           
        } else if(self.presentedViewController) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.controller didAppear];
    
    if(_nextViewController) {
        [self.controller setTopbarStyle:self];
    }
    
    _nextViewController = NO;

}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.controller willAppear];
    
    if(!_nextViewController) {
        [self.controller setTopbarStyle:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KKViewControllerWillAppearNotification object:nil userInfo:@{@"viewController":self}];

}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.controller willDisappear];
    
    [self.controller clearTopbarStyle:self];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.controller didDisappear];
    
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    [_controller.observer set:@[@"page",@"landscape"] value:@(size.width > size.height)];
}

-(void) setAction:(NSDictionary *)action {
    _action = action;
    self.controller.path = [action kk_getString:@"path"];
    self.controller.query = [action kk_getValue:@"query"];
}

+(Class) controllerClass {
    return [KKController class];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    UIInterfaceOrientationMask mask = 0;
    
    id v = [self.controller.observer get:@[@"page",@"orientation"] defaultValue:nil];
    
    if(v) {
        if(![v isKindOfClass:[NSArray class]]) {
            v = @[v];
        }
        
        for(id vv in v) {
            
            NSString * s = [vv kk_stringValue];
            
            if([s isEqualToString:@"landscape-left"]) {
                mask = mask | UIInterfaceOrientationMaskLandscapeLeft;
            } else if([s isEqualToString:@"landscape-right"]) {
                mask = mask | UIInterfaceOrientationMaskLandscapeRight;
            } else if([s isEqualToString:@"portrait"]) {
                mask = mask | UIInterfaceOrientationMaskPortrait;
            } else if([s isEqualToString:@"portrait-upside"]) {
                mask = mask | UIInterfaceOrientationMaskPortraitUpsideDown;
            } else if([s isEqualToString:@"landscape"]) {
                mask = mask | UIInterfaceOrientationMaskLandscape;
            }
            
        }
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return mask;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    id v = [self.controller.observer get:@[@"page",@"orientation"] defaultValue:nil];
    if(v) {
        
        if(![v isKindOfClass:[NSArray class]]) {
            v = @[v];
        }
        
        for(id vv in v) {
            
            NSString * s = [vv kk_stringValue];
            
            if([s isEqualToString:@"landscape-left"]) {
                return UIInterfaceOrientationLandscapeLeft;
            } else if([s isEqualToString:@"landscape-right"]) {
                return UIInterfaceOrientationLandscapeRight;
            } else if([s isEqualToString:@"portrait"]) {
                return UIInterfaceOrientationPortrait;
            } else if([s isEqualToString:@"portrait-upside"]) {
                return UIInterfaceOrientationPortraitUpsideDown;
            } else if([s isEqualToString:@"landscape"]) {
                return UIInterfaceOrientationLandscapeRight;
            }
            
        }
    }
    return UIInterfaceOrientationPortrait;
}


@end
