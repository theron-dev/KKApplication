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
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && value) {
                
                v.view.backgroundColor = [UIColor KKElementStringValue:[value kk_stringValue]];
                
            }
            
        } keys:@[@"page",@"background-color"] context:nil];
        
    }
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && value) {
                
                v.view.tintColor = [UIColor KKElementStringValue:[value kk_stringValue]];
                
            }
            
        } keys:@[@"page",@"tint-color"] context:nil];
        
    }
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id title, NSArray *changedKeys, void *context) {
            
            if(v && title) {
                
                v.title = [title kk_stringValue];
                
            }
            
        } keys:@[@"page",@"title"] context:nil];
        
    }
    
    {
        __weak KKController * ctl = self;
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id data, NSArray *changedKeys, void *context) {
            
            if(v && ctl && data) {
                
                if([data isKindOfClass:[NSDictionary class]]) {
                    UIImage * image = nil;
                    {
                        NSString * v = [data kk_getString:@"image"];
                        if(v != nil && ![@"" isEqualToString:v]) {
                            image = [ctl.application.viewContext imageWithURI:v];
                        }
                    }
                    if(image != nil) {
                        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:ctl action:@selector(doTopbarRightAction:)];
                    } else {
                        NSString * v = [data kk_getString:@"title"];
                        if(v) {
                            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:v style:UIBarButtonItemStylePlain target:ctl action:@selector(doTopbarRightAction:)];
                        }
                    }
                } else {
                    v.navigationItem.rightBarButtonItem = nil;
                }
                
            }
            
        } keys:@[@"page",@"topbar",@"right"] context:nil];
        
    }
    
    {
        __weak KKController * ctl = self;
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id data, NSArray *changedKeys, void *context) {
            
            if(v && ctl && data) {
                
                if([data isKindOfClass:[NSDictionary class]]) {
                    UIImage * image = nil;
                    {
                        NSString * v = [data kk_getString:@"image"];
                        if(v != nil && ![@"" isEqualToString:v]) {
                            image = [ctl.application.viewContext imageWithURI:v];
                        }
                    }
                    if(image != nil) {
                        viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
                    } else {
                        NSString * v = [data kk_getString:@"title"];
                        if(v) {
                            viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:v style:UIBarButtonItemStylePlain target:nil action:nil];
                        }
                    }
                } else {
                    v.navigationItem.backBarButtonItem = nil;
                }
                
            }
            
        } keys:@[@"page",@"topbar",@"back"] context:nil];
        
    }
    
    {
        __weak KKController * ctl = self;
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id data, NSArray *changedKeys, void *context) {
            
            if(v && ctl && data) {
                
                if([data isKindOfClass:[NSDictionary class]]) {
                    UIImage * image = nil;
                    {
                        NSString * v = [data kk_getString:@"image"];
                        if(v != nil && ![@"" isEqualToString:v]) {
                            image = [ctl.application.viewContext imageWithURI:v];
                        }
                    }
                    if(image != nil) {
                        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:ctl action:@selector(doTopbarLeftAction:)];
                    } else {
                        NSString * v = [data kk_getString:@"title"];
                        if(v) {
                            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:v style:UIBarButtonItemStylePlain target:ctl action:@selector(doTopbarLeftAction:)];
                        }
                    }
                } else {
                    v.navigationItem.leftBarButtonItem = nil;
                }
                
            }
            
        } keys:@[@"page",@"topbar",@"left"] context:nil];
        
    }
    
    [self run];
    
    viewController.hidesBottomBarWhenPushed = [[self.observer get:@[@"page",@"bottombar",@"hidden"] defaultValue:@(true)] boolValue];
    
}

-(IBAction) doTopbarLeftAction:(id)sender {
    
    id data = [self.observer get:@[@"page",@"topbar",@"left"] defaultValue:nil];
    
    if([data isKindOfClass:[NSDictionary class]]) {
        NSArray * action = [[data kk_getString:@"action"] componentsSeparatedByString:@"."];
        if(action && [action count] >0 ){
            [self.observer set:action value:[data kk_getValue:@"data"]];
        }
    }
    
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
