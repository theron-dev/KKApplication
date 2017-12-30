//
//  KKController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKController.h"

@implementation KKController

@synthesize application = _application;
@synthesize http = _http;
@synthesize observer = _observer;
@synthesize query = _query;
@synthesize path = _path;

-(void) dealloc {
    [_http cancel];
    [_observer off:nil keys:@[] context:nil];
}

-(KKJSHttp *) http {
    
    if(_http == nil) {
        id<KKHttp> http = [self.application viewContext];
        if(http == nil) {
            http = [KKHttp main];
        }
        _http = [[KKJSHttp alloc] initWithHttp:http];
    }
    
    return _http;
}

-(KKObserver *) observer {
    
    if(_observer == nil) {
        _observer = [self.application newObserver];
    }
    
    if(_observer == nil) {
        _observer = [[KKObserver alloc] init];
    }
    
    return _observer;
}

-(NSDictionary *) query {
    if(_query == nil) {
        _query = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _query;
}


-(void) run {
    
    KKApplication * app = self.application;
    NSString * main = [self.path stringByAppendingString:@".js"];
    
    if(main != nil) {
        
        if([app has:main]) {
            
            [self.application exec:main librarys:@{
                                                   @"http":self.http,
                                                   @"observer":self.observer,
                                                   @"query":self.query,
                                                   @"path":self.path}];
            
        } else {
            NSLog(@"[KK] Not Found %@",[app absolutePath:main]);
        }
        
    }
    
}

-(void) run:(UIViewController *) viewController {
    [self run];
    
    {
        // 背景色
        NSString * v = [[self.observer get:@[@"page",@"background-color"] defaultValue:@"#ffffff"] kk_stringValue];
        viewController.view.backgroundColor = [UIColor KKElementStringValue:v];
    }
    
    {
        // 标题
        NSString * v = [[self.observer get:@[@"page",@"title"] defaultValue:viewController.title] kk_stringValue];
        viewController.title = v;
    }
    
    {
        // 顶部导航 右侧
        id data = [self.observer get:@[@"page",@"topbar",@"right"] defaultValue:nil];
        
        if([data isKindOfClass:[NSDictionary class]]) {
            UIImage * image = nil;
            {
                NSString * v = [data kk_getString:@"image"];
                if(v != nil && ![@"" isEqualToString:v]) {
                    image = [self.application.viewContext imageWithURI:v];
                }
            }
            if(image != nil) {
                viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(doTopbarRightAction:)];
            } else {
                NSString * v = [data kk_getString:@"title"];
                if(v) {
                    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:v style:UIBarButtonItemStylePlain target:self action:@selector(doTopbarRightAction:)];
                }
            }
        }
    }
    
    viewController.hidesBottomBarWhenPushed = [[self.observer get:@[@"page",@"bottombar",@"hidden"] defaultValue:@(true)] boolValue];
    
}

-(IBAction) doTopbarRightAction:(id)sender {
    
    id data = [self.observer get:@[@"page",@"topbar",@"right"] defaultValue:nil];
    
    if([data isKindOfClass:[NSDictionary class]]) {
        NSArray * action = [[data kk_getString:@"action"] componentsSeparatedByString:@"."];
        if(action && [action count] >0 ){
            [self.observer set:action value:[data kk_getValue:@"data"]];
        }
    }
    
}

-(void) willAppear {
    [self.observer changeKeys:@[@"page",@"willAppear"]];
}

-(void) didAppear {
    [self.observer changeKeys:@[@"page",@"didAppear"]];
}

-(void) willDisappear {
    [self.observer changeKeys:@[@"page",@"willDisappear"]];
}

-(void) didDisappear {
    [self.observer changeKeys:@[@"page",@"didDisappear"]];
}

@end
