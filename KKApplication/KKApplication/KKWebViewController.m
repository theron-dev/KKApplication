//
//  KKWebViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewController.h"
#import <WebKit/WebKit.h>


@interface KKWebViewController ()

@end

@implementation KKWebViewController

@synthesize application = _application;
@synthesize pageController = _pageController;
@synthesize action = _action;

-(void) loadView {
    self.view = [self loadWebView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL * u = nil;
    if([self.url hasPrefix:@"app://"]) {
        u = [NSURL fileURLWithPath:[[self.application path] stringByAppendingPathComponent:[self.url substringFromIndex:6]] ];
    } else {
        u = [NSURL URLWithString:self.url];
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:u]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setAction:(NSDictionary *)action {
    _action = action;
    NSString * v =  [action kk_getString:@"url"];
    if(v == nil) {
        v = [action kk_getString:@"scheme"];
    }
    self.url = v;
}

-(WKWebView *) webView {
    return (WKWebView *) self.view;
}

-(UIView *) contentView {
    WKWebView * view = self.webView;
    return view.scrollView;
}

-(WKWebView *) loadWebView {
    WKWebViewConfiguration * v = [self loadWebViewConfiguration];
    if(v == nil) {
        return [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    return [[WKWebView alloc] initWithFrame:CGRectZero configuration:v];
}

-(WKWebViewConfiguration *) loadWebViewConfiguration {
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController * userContentController = [[WKUserContentController alloc] init];
    
    [userContentController addUserScript:[[WKUserScript alloc] initWithSource:@"kk = { run : function(path,query) { window.webkit.messageHandlers.run.postMessage({ path : path, query: query}); } , setData:function(data) { window.webkit.messageHandlers.data.postMessage(data); }, onData:function(){} }" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
    
    [userContentController addScriptMessageHandler:self name:@"run"];
    [userContentController addScriptMessageHandler:self name:@"data"];
    
    configuration.userContentController = userContentController;
    
    return configuration;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if([message.name isEqualToString:@"run"]) {
        [_pageController recycle];
        _pageController = [[KKPageController alloc] init];
        _pageController.application = self.application;
        _pageController.path = [message.body kk_getString:@"path"];
        _pageController.query = [message.body kk_getValue:@"query"];
        
        {
            __weak WKWebView * view = self.webView;
            
            [_pageController.observer on:^(id value, NSArray *changedKeys, void *context) {
                
                if(view) {
                    
                    NSData * data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
    
                    [view evaluateJavaScript:[NSString stringWithFormat:@"kk.onData(%@);",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]] completionHandler:nil];
                    
                }
                
            } keys:@[@"action",@"data"] context:nil];
        
        }
        [_pageController run:self];
    } else if([message.name isEqualToString:@"data"]) {
        
        if([message.body isKindOfClass:[NSDictionary class]]) {
            NSEnumerator * keyEnum = [message.body keyEnumerator];
            NSString * key;
            while((key = [keyEnum nextObject])) {
                [_pageController.observer set:@[key] value:[message.body kk_getValue:key]];
            }
        }
    }
}

@end
