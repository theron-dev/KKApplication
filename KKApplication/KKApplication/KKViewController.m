//
//  KKViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKViewController.h"


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

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
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

-(void) setAction:(NSDictionary *)action {
    _action = action;
    self.controller.path = [action kk_getString:@"path"];
    self.controller.query = [action kk_getValue:@"query"];
}

+(Class) controllerClass {
    return [KKController class];
}

@end
