//
//  KKViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKViewController.h"


@interface KKViewController () {
    BOOL _topbar_hidden;
    UIColor * _topbar_backgroundColor;
    UIColor * _topbar_tintColor;
    UIColor * _topbar_barTintColor;
    UIImage * _topbar_backgroundImage;
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
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            _topbar_hidden = [self.navigationController isNavigationBarHidden];
            [self.navigationController setNavigationBarHidden:[v boolValue] animated:NO];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        if(v) {
            
            UIImage * image = [self.application.viewContext imageWithURI:v];
            
            _topbar_backgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
            
            [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            
            if(image) {
                [self.navigationController.navigationBar setClipsToBounds:YES];
            }
            
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            _topbar_backgroundColor = [self.navigationController.navigationBar backgroundColor];
            [self.navigationController.navigationBar setBackgroundColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            _topbar_tintColor = [self.navigationController.navigationBar tintColor];
            [self.navigationController.navigationBar setTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            _topbar_barTintColor = [self.navigationController.navigationBar barTintColor];
            [self.navigationController.navigationBar setBarTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    [self.controller willAppear];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            [self.navigationController setNavigationBarHidden:_topbar_hidden animated:NO];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        if(v) {
            
            [self.navigationController.navigationBar setBackgroundImage:_topbar_backgroundImage forBarMetrics:UIBarMetricsDefault];
            
            [self.navigationController.navigationBar setClipsToBounds:_topbar_backgroundImage != nil];
            
        }
    }
    
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setBackgroundColor:_topbar_backgroundColor];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setTintColor:_topbar_tintColor];
        }
    }
    
    {
        id v = [self.controller.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setBarTintColor:_topbar_barTintColor];
        }
    }
    
    [self.controller willDisappear];
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
