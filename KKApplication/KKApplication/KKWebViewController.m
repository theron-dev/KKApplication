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

@property(nonatomic,strong) NSMutableDictionary * styleSheet;
@property(nonatomic,strong) KKBodyElement * bodyElement;
@property(nonatomic,strong) NSMutableDictionary * elements;

@end

@implementation KKWebViewController

@synthesize webView = _webView;
@synthesize application = _application;
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

-(NSMutableDictionary *) styleSheet {
    if(_styleSheet == nil) {
        _styleSheet = [[NSMutableDictionary alloc] initWithCapacity:4];
        NSURL * u = [NSURL URLWithString:self.url];
        if(u && [u.fragment hasPrefix:@"#"]) {
            NSArray * items = [[u.fragment substringFromIndex:1] componentsSeparatedByString:@"}"];
            for(NSString * item in items) {
                NSArray * nv = [item componentsSeparatedByString:@"{"];
                if([nv count] > 1) {
                    NSString * name= [nv[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSMutableDictionary* attrs = [NSMutableDictionary dictionaryWithCapacity:4];
                    NSArray * kv = [nv[1] componentsSeparatedByString:@";"];
                    
                    for(NSString * v in kv) {
                        NSArray * kvv = [v componentsSeparatedByString:@":"];
                        if([kvv count] > 1) {
                            NSString * key = [kvv[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString * value = [kvv[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            [attrs setObject:value forKey:key];
                        }
                    }
                    
                    [_styleSheet setObject:attrs forKey:name];
                }
            }
        }
    }
    return _styleSheet;
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
    
    [userContentController addUserScript:[[WKUserScript alloc] initWithSource:@"kk = { add : function(id,name,attrs,pid) { window.webkit.messageHandlers.add.postMessage({ id : id, name: name , attrs : attrs, pid : pid}); } , remove:function(id) { window.webkit.messageHandlers.remove.postMessage({ id : id}); }, set:function(id,key,value) {window.webkit.messageHandlers.set.postMessage({ id : id , key:key , value: value});} ,  onEvent:function(id,name,data) { var e = document.getElementById(id); if(e) { var ev = new Event(name); ev.data = data; e.dispatchEvent(ev); } } , on:function(id,name){ window.webkit.messageHandlers.on.postMessage({ id : id, name : name}); }, off:function(id,name){ window.webkit.messageHandlers.off.postMessage({ id : id, name : name}); } ,commit : function() { window.webkit.messageHandlers.commit.postMessage({ }); }}" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
    
    [userContentController addScriptMessageHandler:self name:@"add"];
    [userContentController addScriptMessageHandler:self name:@"remove"];
    [userContentController addScriptMessageHandler:self name:@"set"];
    [userContentController addScriptMessageHandler:self name:@"on"];
    [userContentController addScriptMessageHandler:self name:@"off"];
    [userContentController addScriptMessageHandler:self name:@"commit"];
    
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
        
        self.webView.opaque = NO;
        
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
    
    NSDictionary * styleSheet = [self styleSheet];
 
    {
        id v = [styleSheet valueForKeyPath:@"topbar.hidden"];
        
        if(v) {
            _topbar_hidden = [self.navigationController isNavigationBarHidden];
            [self.navigationController setNavigationBarHidden:KKBooleanValue(v) animated:NO];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.background-color"];
        if(v) {
            _topbar_backgroundColor = [self.navigationController.navigationBar backgroundColor];
            [self.navigationController.navigationBar setBackgroundColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.tint-color"];
        if(v) {
            _topbar_tintColor = [self.navigationController.navigationBar tintColor];
            [self.navigationController.navigationBar setTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.bar-tint-color"];
        if(v) {
            _topbar_barTintColor = [self.navigationController.navigationBar barTintColor];
            [self.navigationController.navigationBar setBarTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSDictionary * styleSheet = [self styleSheet];
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.hidden"];
        if(v) {
            [self.navigationController setNavigationBarHidden:_topbar_hidden animated:NO];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.background-color"];
        if(v) {
            [self.navigationController.navigationBar setBackgroundColor:_topbar_backgroundColor];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.tint-color"];
        if(v) {
            [self.navigationController.navigationBar setTintColor:_topbar_tintColor];
        }
    }
    
    {
        id v = [styleSheet valueForKeyPath:@"topbar.bar-tint-color"];
        if(v) {
            [self.navigationController.navigationBar setBarTintColor:_topbar_barTintColor];
        }
    }

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

@end
