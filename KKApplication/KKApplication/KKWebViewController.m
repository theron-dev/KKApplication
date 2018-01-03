//
//  KKWebViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewController.h"
#import <WebKit/WebKit.h>


@interface KKWebViewController () {
    BOOL _topbar_hidden;
    UIColor * _topbar_backgroundColor;
    UIColor * _topbar_tintColor;
    UIColor * _topbar_barTintColor;
}

@end

@implementation KKWebViewController

@synthesize webView = _webView;
@synthesize application = _application;
@synthesize pageController = _pageController;
@synthesize action = _action;

-(WKWebView *) webView {
    if(_webView == nil) {
        _webView = [self loadWebView];
        [_webView setNavigationDelegate:self];
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        WKWebView * v = self.webView;
        v.frame = self.view.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:v];
    }
    
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
    
    {
        NSString * v = [self.action kk_getString:@"beforeScript"];
        if([v length]) {
            NSString * code = [NSString stringWithContentsOfFile:[[self.application path] stringByAppendingPathComponent:v] encoding:NSUTF8StringEncoding error:nil ];
            if(code) {
                [userContentController addUserScript:[[WKUserScript alloc] initWithSource:code injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
            }
        }
    }
    
    {
        NSString * v = [self.action kk_getString:@"afterScript"];
        if([v length]) {
            NSString * code = [NSString stringWithContentsOfFile:[[self.application path] stringByAppendingPathComponent:v] encoding:NSUTF8StringEncoding error:nil ];
            if(code) {
                [userContentController addUserScript:[[WKUserScript alloc] initWithSource:code injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];
            }
        }
    }
    
    [userContentController addScriptMessageHandler:self name:@"run"];
    [userContentController addScriptMessageHandler:self name:@"data"];
    
    configuration.userContentController = userContentController;
    
    return configuration;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if([message.name isEqualToString:@"run"]) {
        
        self.webView.opaque = NO;
        
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
        
        {
            // 关闭
            __weak KKWebViewController * v = self;
            [_pageController.observer on:^(id value, NSArray *changedKeys, void *context) {
                
                [v doCloseAction:nil];
                
            } keys:@[@"action",@"close"] context:nil];
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


-(IBAction) doCloseAction:(id)sender {
    
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.pageController didAppear];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            _topbar_hidden = [self.navigationController isNavigationBarHidden];
            [self.navigationController setNavigationBarHidden:[v boolValue] animated:NO];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            _topbar_backgroundColor = [self.navigationController.navigationBar backgroundColor];
            [self.navigationController.navigationBar setBackgroundColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            _topbar_tintColor = [self.navigationController.navigationBar tintColor];
            [self.navigationController.navigationBar setTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            _topbar_barTintColor = [self.navigationController.navigationBar barTintColor];
            [self.navigationController.navigationBar setBarTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    [self.pageController willAppear];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            [self.navigationController setNavigationBarHidden:_topbar_hidden animated:NO];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setBackgroundColor:_topbar_backgroundColor];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setTintColor:_topbar_tintColor];
        }
    }
    
    {
        id v = [self.pageController.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            [self.navigationController.navigationBar setBarTintColor:_topbar_barTintColor];
        }
    }
    
    [self.pageController willDisappear];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.pageController didDisappear];
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.pageController layout:self];
}

-(void) doAction:(NSDictionary *) action {
    
    NSArray * keys = [[action kk_getString:@"keys"] componentsSeparatedByString:@"."];
    
    NSDictionary * data = [action kk_getValue:@"data"];
    
    NSMutableDictionary * vv = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if([data isKindOfClass:[NSDictionary class]]) {
        [vv addEntriesFromDictionary:data];
    }
    
    vv[@"url"] = [action kk_getString:@"url"];
    
    NSLog(@"[KK] %@",[action kk_getString:@"url"]);
    
    if([keys count] > 0) {
        
        if(self.pageController == nil) {
            [self.application.observer set:keys value:vv];
        } else {
            [self.pageController.observer set:keys value:vv];
        }
        
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSArray * actions = [self.action kk_getValue:@"actions"];
    
    NSString * url = [navigationAction.request.URL absoluteString];
    
    if([actions isKindOfClass:[NSArray class]]) {
        
        for(NSDictionary * action in actions) {
            
            NSString * v = [action kk_getString:@"prefix"];
            
            if(v && [url hasPrefix:v] ) {
                
                NSMutableDictionary * vv = [NSMutableDictionary dictionaryWithDictionary:action];
                
                vv[@"url"] = url;
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [self performSelector:@selector(doAction:) withObject:vv afterDelay:0.03];
                
                decisionHandler(WKNavigationActionPolicyCancel);
                
                return;
            }
            
        }
        
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
