//
//  KKWebViewBridge.m
//  KKApplication
//
//  Created by zhanghailong on 2018/1/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewBridge.h"
#import <KKView/KKView.h>

@interface KKWebViewBridge() {
    
}

@end

@implementation KKWebViewBridge

@synthesize viewController = _viewController;
@synthesize onevent = _onevent;
@synthesize onappforeground = _onappforeground;
@synthesize onappbackground = _onappbackground;

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(instancetype) initWithViewController:(UIViewController<KKWebViewBridgeViewController> *) viewController {
    if((self = [super init])) {
        _viewController = viewController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

-(void) UIApplicationDidEnterBackgroundNotification {
    @try{
        [self.onappbackground callWithArguments:@[]];
    }
    @catch(NSException * ex) {
        NSLog(@"[KK] %@",ex);
    }
}

-(void) UIApplicationWillEnterForegroundNotification {
    @try{
        [self.onappforeground callWithArguments:@[]];
    }
    @catch(NSException * ex) {
        NSLog(@"[KK] %@",ex);
    }
}

-(void) add:(NSString *) elementId name:(NSString *) name attrs:(NSDictionary *) attrs parentId:(NSString *) parentId {
    
    if(elementId && name) {
        
        __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(viewController) {
                
                KKElement * e = [viewController.elements objectForKey:elementId];
            
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
            
                if(parentId) {
                    parent = [viewController.elements objectForKey:parentId];
                }
            
                if(parent == nil) {
                    [viewController.bodyElement append:e];
                } else {
                    [parent append:e];
                }
            
                [viewController.elements setObject:e forKey:elementId];
                [viewController.elementKeys addObject:elementId];
            }
        });
        
    }
}



-(void) remove:(NSString *) elementId {
    if(elementId) {
        
        __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(viewController) {
                [viewController removeElement:[viewController.elements objectForKey:elementId]];
            }
        });
        
    }
}

-(void) set:(NSString *) elementId key:(NSString *) key value:(NSString *) value {
    
    if(elementId && key) {
        
        __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(viewController) {
                KKElement * e = [viewController.elements objectForKey:elementId];
                if(e) {
                    [e set:key value:value];
                }
            }
        });
        
    }
}

-(void) on:(NSString *) elementId name:(NSString *) name {
    
    if(elementId && name) {
        
        __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
        __weak KKWebViewBridge * v = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(v && viewController) {
                KKElement * e = [viewController.elements objectForKey:elementId];
                if(e) {
                    [e on:name fn:^(KKEvent *event, void *context) {
                        
                        if(v && [event isKindOfClass:[KKElementEvent class]]) {
                            KKElementEvent * e = (KKElementEvent *) event;
                            NSData * data = [NSJSONSerialization dataWithJSONObject:e.data options:NSJSONWritingPrettyPrinted error:nil];
                            if(v && v.onevent) {
                                @try{
                                    [v.onevent callWithArguments:@[elementId,name,data]];
                                }
                                @catch(NSException * ex) {
                                    NSLog(@"[KK] %@",ex);
                                }
                            }
                            if(v && v.onEvent) {
                                v.onEvent(elementId, name, data);
                            }
                        }
                        
                    } context:nil];
                    
                }
            }
        });
        
    }
    
}

-(void) off:(NSString *) elementId name:(NSString *) name {
    if(elementId && name) {
        
        __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(viewController) {
                KKElement * e = [viewController.elements objectForKey:elementId];
                if(e) {
                    [e off:name fn:nil context:nil];
                }
            }
        });
        
    }
}

-(void) commit {
    
    __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
    __weak KKWebViewBridge * v = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(viewController && v) {
            
            if([viewController respondsToSelector:@selector(KKWebViewBridgeCommit:)]) {
                if([viewController KKWebViewBridgeCommit:v]) {
                    return;
                }
            }
            
            for(NSString * elementId in [viewController.elements allKeys]) {
                if(! [viewController.elementKeys containsObject:elementId]) {
                    KKElement * e = [viewController.elements valueForKey:elementId];
                    [e remove];
                    [viewController.elements removeObjectForKey:elementId];
                }
            }
            
            [viewController.elementKeys removeAllObjects];
            
            UIView * view = viewController.contentView;
            [viewController.bodyElement layout:view.bounds.size];
            [viewController.bodyElement obtainView:view];
        }
        
    });
    
}

-(void) close {
    
    __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
    __weak KKWebViewBridge * v = self;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(viewController && v) {
            
            if([viewController respondsToSelector:@selector(KKWebViewBridgeClose:)]) {
                if([viewController KKWebViewBridgeClose:v]) {
                    return;
                }
            }
            
            if(viewController.navigationController) {
                [viewController.navigationController popViewControllerAnimated:YES];
            } else if(self.viewController.presentedViewController) {
                [viewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
    });
    
}

-(void) style:(NSString *) name data:(NSDictionary *) data {
    
    __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
    __weak KKWebViewBridge * v = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(viewController && v) {
            if([viewController respondsToSelector:@selector(KKWebViewBridge:style:data:)]) {
                if([viewController KKWebViewBridge:v style:name data:data]) {
                    return ;
                }
            }
            if([name isEqualToString:@"topbar"]) {
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                    if(v) {
                        viewController.navigationController.navigationBar.backgroundColor = v;
                    }
                }
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                    if(v) {
                        viewController.navigationController.navigationBar.tintColor = v;
                    }
                }
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"bar-tint-color"]];
                    if(v) {
                        viewController.navigationController.navigationBar.barTintColor = v;
                    }
                }
                {
                    id v = [data kk_getValue:@"hidden"];
                    if(v) {
                        [viewController setTopbarHidden:[v boolValue]];
                    }
                }
            } else if([name isEqualToString:@"view"]) {
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                    if(v) {
                        self.viewController.view.backgroundColor = v;
                    }
                }
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                    if(v) {
                        viewController.view.tintColor = v;
                    }
                }
            } else if([name isEqualToString:@"contentView"]) {
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                    if(v) {
                        viewController.contentView.backgroundColor = v;
                    }
                }
                {
                    UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                    if(v) {
                        viewController.contentView.tintColor = v;
                    }
                }
            }
        }
    });
}

-(void) gesture:(NSDictionary *) gesture {
    
    __weak UIViewController<KKWebViewBridgeViewController> * viewController = self.viewController;
    __weak KKWebViewBridge * v = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(viewController && v) {
            
            if([viewController respondsToSelector:@selector(KKWebViewBridge:gesture:)]) {
                if([viewController KKWebViewBridge:v gesture:gesture]) {
                    return ;
                }
            }
            
            {
                id v = [gesture kk_getValue:@"back"];
                if(KKBooleanValue(v)) {
                    viewController.navigationController.interactivePopGestureRecognizer.enabled = true;
                } else {
                    viewController.navigationController.interactivePopGestureRecognizer.enabled = false;
                }
            }
            
        }
        
    });
}

@end
