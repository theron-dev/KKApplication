//
//  KKWebViewController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewController.h"
#import <WebKit/WebKit.h>

#include <objc/runtime.h>

@implementation KKApplication (KKWebViewController)

-(WKProcessPool *) processPool {
    WKProcessPool * v = objc_getAssociatedObject(self, "_processPool");
    if(v == nil) {
        v = [[WKProcessPool alloc] init];
        objc_setAssociatedObject(self, "_processPool", v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return v;
}

-(void) setProcessPool:(WKProcessPool *)processPool {
    objc_setAssociatedObject(self, "_processPool", processPool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface KKWebViewController () {
    NSNumber * _topbar_hidden;
    UIColor * _topbar_backgroundColor;
    UIColor * _topbar_tintColor;
    UIColor * _topbar_barTintColor;
}

@property(nonatomic,strong) KKBodyElement * bodyElement;
@property(nonatomic,strong) NSMutableDictionary * elements;

@end

@implementation KKWebViewController

@synthesize webView = _webView;
@synthesize application = _application;
@synthesize action = _action;
@synthesize processPool = _processPool;
@synthesize cookies = _cookies;

-(void) dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"KKWebViewController dealloc");
}

-(WKWebView *) webView {
    if(_webView == nil) {
        _webView = [self loadWebView];
        [_webView setNavigationDelegate:self];
        [_webView setUIDelegate:self];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if(object == _webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:_webView.estimatedProgress animated:YES];
        [self.progressView setHidden:_webView.estimatedProgress>=1];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    {
        WKWebView * v = self.webView;
        v.frame = self.view.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:v];
    }
    
    {
        CGSize size = self.view.bounds.size;
        UIProgressView * v = [self progressView];
        v.frame = CGRectMake(0, 64, size.width, 4);
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:v];
    }
    
    NSString * url = self.url;
    
    NSRange r = [url rangeOfString:@"#"];
    if(r.length >0 && r.location != NSNotFound) {
        url = [url substringToIndex:r.location];
    }
    
    NSURL * u = nil;
    if([url hasPrefix:@"app://"]) {
        u = [NSURL fileURLWithPath:[[self.application path] stringByAppendingPathComponent:[url substringFromIndex:6]] ];
    } else {
        u = [NSURL URLWithString:url];
    }
    
    if(_cookies == nil) {
        _cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:u];
    }

    [self.webView loadRequest:[NSURLRequest requestWithURL:u]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(WKProcessPool *) processPool {
    if(_processPool == nil) {
        _processPool = self.application.processPool;
    }
    return _processPool;
}

-(UIProgressView *) progressView {
    if(_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

-(void) setAction:(NSDictionary *)action {
    _action = action;
    NSString * v =  [action kk_getString:@"url"];
    if(v == nil) {
        v = [action kk_getString:@"scheme"];
    }
    self.url = v;
}

-(NSMutableDictionary *) elements {
    if(_elements == nil) {
        _elements = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _elements;
}

-(KKBodyElement *) bodyElement {
    if(_bodyElement == nil) {
        _bodyElement = [[KKBodyElement alloc] init];
        [_bodyElement setLayout:KKViewElementLayoutRelative];
    }
    return _bodyElement;
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
    
    configuration.processPool = self.processPool;
    
    WKUserContentController * userContentController = [[WKUserContentController alloc] init];
    
    {
        NSMutableString * v = [NSMutableString stringWithCapacity:64];
        
        for(NSHTTPCookie * cookie in self.cookies) {
            [v appendFormat:@"%@=%@; ",cookie.name,cookie.value];
        }
        
        [userContentController addUserScript:[[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"if(!document.referrer){ document.cookie = \"%@\"; }",v] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
    }
    
    {
        [userContentController addUserScript:[[WKUserScript alloc] initWithSource:@"window.kk = { add : function(id,name,attrs,pid) { window.webkit.messageHandlers.add.postMessage({ id : id, name: name , attrs : attrs, pid : pid}); } , remove:function(id) { window.webkit.messageHandlers.remove.postMessage({ id : id}); }, set:function(id,key,value) {window.webkit.messageHandlers.set.postMessage({ id : id , key:key , value: value});} ,  onEvent:function(id,name,data) { var e = document.getElementById(id); if(e) { var ev = new Event(name); ev.data = data; e.dispatchEvent(ev); } } , on:function(id,name){ window.webkit.messageHandlers.on.postMessage({ id : id, name : name}); }, off:function(id,name){ window.webkit.messageHandlers.off.postMessage({ id : id, name : name}); } ,commit : function() { window.webkit.messageHandlers.commit.postMessage({ }); } , style:function(name,data) {window.webkit.messageHandlers.style.postMessage({ name : name, data: data });} , close:function(){window.webkit.messageHandlers.close.postMessage({});} , gesture:function(enabled){window.webkit.messageHandlers.gesture.postMessage({ back : enabled });} }" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
        
        [userContentController addScriptMessageHandler:self name:@"add"];
        [userContentController addScriptMessageHandler:self name:@"remove"];
        [userContentController addScriptMessageHandler:self name:@"set"];
        [userContentController addScriptMessageHandler:self name:@"on"];
        [userContentController addScriptMessageHandler:self name:@"off"];
        [userContentController addScriptMessageHandler:self name:@"commit"];
        [userContentController addScriptMessageHandler:self name:@"style"];
        [userContentController addScriptMessageHandler:self name:@"close"];
        [userContentController addScriptMessageHandler:self name:@"gesture"];
    }
    
    configuration.userContentController = userContentController;
    
    return configuration;
}

-(void) removeElement:(KKElement *) element {
    if(element == nil) {
        return;
    }
    KKElement * p = element.firstChild,*n;
    while(p) {
        n = p.nextSibling;
        [self removeElement:p];
        p = n;
    }
    NSString * elementId = [element get:@"id"];
    [element remove];
    if(elementId) {
        [[self elements] removeObjectForKey:elementId];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if([message.name isEqualToString:@"add"]) {
        
        NSString * elementId = [message.body kk_getString:@"id"];
        NSString * name = [message.body kk_getString:@"name"];
        NSString * pid = [message.body kk_getString:@"pid"];
        NSDictionary * attrs = [message.body kk_getValue:@"attrs"];
        
        if(elementId && name) {
            
            KKElement* e = [self.elements objectForKey:elementId];
            
            if(e == nil) {
                Class isa = NSClassFromString( [[KKViewContext defaultElementClass] objectForKey:name] );
                if(isa == nil) {
                    e = [[KKViewElement alloc] init];
                } else {
                    e = [[isa alloc] init];
                }
            }
            
            if([attrs isKindOfClass:[NSDictionary class]]) {
                [e setAttrs:attrs];
            }
            
            [e set:@"id" value:elementId];
            
            KKElement* parent = nil;
            
            if(pid) {
                parent = [self.elements objectForKey:pid];
            }
            
            if(parent == nil) {
                [self.bodyElement append:e];
            } else {
                [parent append:e];
            }
            
            [self.elements setObject:e forKey:elementId];
        }
        
    } else if([message.name isEqualToString:@"remove"]) {
        
        NSString * elementId = [message.body kk_getString:@"id"];
        
        if(elementId) {
            [self removeElement:[self.elements objectForKey:elementId]];
        }
        
    } else if([message.name isEqualToString:@"set"]) {
        
        NSString * elementId = [message.body kk_getString:@"id"];
        NSString * key = [message.body kk_getString:@"key"];
        NSString * value = [message.body kk_getString:@"value"];
        
        if(elementId && key) {
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                [e set:key value:value];
            }
        }
    } else if([message.name isEqualToString:@"on"]) {
        
        NSString * elementId = [message.body kk_getString:@"id"];
        NSString * name = [message.body kk_getString:@"name"];
        
        if(elementId && name) {
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                
                __weak WKWebView * v = self.webView;
                
                [e on:name fn:^(KKEvent *event, void *context) {
                    
                    if(v && [event isKindOfClass:[KKElementEvent class]]) {
                        KKElementEvent * e = (KKElementEvent *) event;
                        NSData * data = [NSJSONSerialization dataWithJSONObject:e.data options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *code = [NSString stringWithFormat:@"kk.onEvent(\"%@\",%@);",name,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                        [v evaluateJavaScript:code completionHandler:^(id r, NSError * error) {
                            if(error) {
                                NSLog(@"[KK] %@",error);
                            }
                        }];
                    }
                    
                } context:nil];
                
            }
        }
    } else if([message.name isEqualToString:@"off"]) {
        
        NSString * elementId = [message.body kk_getString:@"id"];
        NSString * name = [message.body kk_getString:@"name"];
        
        if(elementId && name) {
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                [e off:name fn:nil context:nil];
            }
        }
    } else if([message.name isEqualToString:@"commit"]) {
        
        self.webView.opaque = NO;
        
        UIView * view = self.contentView;
        
        [_bodyElement layout:view.bounds.size];
        [_bodyElement obtainView:view];
        
    } else if([message.name isEqualToString:@"style"]) {
        NSString * name = [message.body kk_getString:@"name"];
        NSDictionary * data = [message.body kk_getValue:@"data"];
        if([name isEqualToString:@"topbar"]) {
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                if(v) {
                    self.navigationController.navigationBar.backgroundColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                if(v) {
                    self.navigationController.navigationBar.tintColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"bar-tint-color"]];
                if(v) {
                    self.navigationController.navigationBar.barTintColor = v;
                }
            }
            {
                id v = [data kk_getValue:@"hidden"];
                if(v) {
                    [self.navigationController setNavigationBarHidden:[v boolValue] animated:NO];
                    
                }
            }
        } else if([name isEqualToString:@"view"]) {
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                if(v) {
                    self.view.backgroundColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                if(v) {
                    self.view.tintColor = v;
                }
            }
        } else if([name isEqualToString:@"progress"]) {
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                if(v) {
                    self.progressView.trackTintColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                if(v) {
                    self.progressView.progressTintColor = v;
                }
            }
        }
    } else if([message.name isEqualToString:@"close"]) {
        [self doCloseAction:nil];
    } else if([message.name isEqualToString:@"gesture"]) {
        {
            id v = [message.body kk_getValue:@"back"];
            if(KKBooleanValue(v)) {
                self.navigationController.interactivePopGestureRecognizer.enabled = true;
            } else {
                self.navigationController.interactivePopGestureRecognizer.enabled = false;
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


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _topbar_hidden = @([self.navigationController isNavigationBarHidden]);
    _topbar_backgroundColor = self.navigationController.navigationBar.backgroundColor;
    _topbar_tintColor = self.navigationController.navigationBar.tintColor;
    _topbar_barTintColor = self.navigationController.navigationBar.barTintColor;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:[_topbar_hidden boolValue] animated:NO];
    [self.navigationController.navigationBar setBackgroundColor:_topbar_backgroundColor];
    [self.navigationController.navigationBar setTintColor:_topbar_tintColor];
    [self.navigationController.navigationBar setBarTintColor:_topbar_barTintColor];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

}


-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_bodyElement layout:self.view.bounds.size];
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
        
        [self.application.observer set:keys value:vv];
        
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if([self.title length] == 0) {
        __weak KKWebViewController * v = self;
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id value, NSError * error) {
            v.title = KKStringValue(value);
        }];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    completionHandler();
}

@end
