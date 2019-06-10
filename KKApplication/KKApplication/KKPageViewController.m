//
//  KKPageViewController.m
//  KKApplication
//
//  Created by zhanghailong on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKPageViewController.h"
#import <KKHttp/KKHttp.h>

@interface KKPageViewController ()

@end

@implementation KKPageViewController

-(instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

-(void) dealloc {
    NSLog(@"KKPageViewController dealloc");
}

+(Class) controllerClass {
    return [KKPageController class];
}

-(KKPageController *) pageController {
    return (KKPageController *) self.controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pageController installTopbar:self];
    
}

-(UIView *) contentView {
    if(_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight];
        [self.view insertSubview:_contentView atIndex:0];
    }
    return _contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.pageController layout:self];
    [self.pageController layoutTopbar:self];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pageController layoutTopbar:self];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pageController layoutTopbar:self];
}

-(void) setAction:(NSDictionary *)action {
    [super setAction:action];
    self.pageController.viewPath = [action kk_getString:@"view"];
}

@end
