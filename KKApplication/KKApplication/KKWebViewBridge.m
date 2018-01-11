//
//  KKWebViewBridge.m
//  KKApplication
//
//  Created by hailong11 on 2018/1/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKWebViewBridge.h"
#import <KKView/KKView.h>

@interface KKWebViewBridge() {
    
}

@property(nonatomic,strong) NSMutableSet * keys;
@property(nonatomic,strong) NSMutableDictionary * elements;
@property(nonatomic,strong) KKBodyElement * bodyElement;

@end

@implementation KKWebViewBridge

@synthesize bodyElement = _bodyElement;
@synthesize elements = _elements;
@synthesize viewController = _viewController;
@synthesize onevent = _onevent;

-(NSMutableDictionary *) elements {
    if(_elements == nil) {
        _elements = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _elements;
}

-(NSMutableSet *) keys{
    if(_keys == nil) {
        _keys = [[NSMutableSet alloc] initWithCapacity:4];
    }
    return _keys;
}

-(KKBodyElement *) bodyElement {
    if(_bodyElement == nil) {
        _bodyElement = [[KKBodyElement alloc] init];
        [_bodyElement setLayout:KKViewElementLayoutRelative];
    }
    return _bodyElement;
}

-(instancetype) initWithViewController:(UIViewController<KKWebViewBridgeViewController> *) viewController {
    if((self = [super init])) {
        _viewController = viewController;
    }
    return self;
}


-(void) add:(NSString *) elementId name:(NSString *) name attrs:(NSDictionary *) attrs parentId:(NSString *) parentId {
    
    if(elementId && name) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            KKElement * e = [self.elements objectForKey:elementId];
        
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
                parent = [self.elements objectForKey:parentId];
            }
        
            if(parent == nil) {
                [self.bodyElement append:e];
            } else {
                [parent append:e];
            }
        
            [self.elements setObject:e forKey:elementId];
            [self.keys addObject:elementId];
            
        });
        
    }
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

-(void) remove:(NSString *) elementId {
    if(elementId) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeElement:[self.elements objectForKey:elementId]];
        });
        
    }
}

-(void) set:(NSString *) elementId key:(NSString *) key value:(NSString *) value {
    
    if(elementId && key) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                [e set:key value:value];
            }
            
        });
        
    }
}

-(void) on:(NSString *) elementId name:(NSString *) name {
    
    if(elementId && name) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                
                __weak KKWebViewBridge * v = self;
                
                [e on:name fn:^(KKEvent *event, void *context) {
                    
                    if(v && [event isKindOfClass:[KKElementEvent class]]) {
                        KKElementEvent * e = (KKElementEvent *) event;
                        NSData * data = [NSJSONSerialization dataWithJSONObject:e.data options:NSJSONWritingPrettyPrinted error:nil];
                        if(v && v.onevent) {
                            [v.onevent callWithArguments:@[elementId,name,data]];
                        }
                        if(v && v.onEvent) {
                            v.onEvent(elementId, name, data);
                        }
                    }
                    
                } context:nil];
                
            }
            
        });
        
    }
    
}

-(void) off:(NSString *) elementId name:(NSString *) name {
    if(elementId && name) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            KKElement * e = [self.elements objectForKey:elementId];
            if(e) {
                [e off:name fn:nil context:nil];
            }
        });
        
    }
}

-(void) commit {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_viewController respondsToSelector:@selector(KKWebViewBridgeCommit:)]) {
            if([_viewController KKWebViewBridgeCommit:self]) {
                return;
            }
        }
        
        for(NSString * elementId in [self.elements allKeys]) {
            if(! [self.keys containsObject:elementId]) {
                KKElement * e = [self.elements valueForKey:elementId];
                [e remove];
                [self.elements removeObjectForKey:elementId];
            }
        }
        
        [self.keys removeAllObjects];
        
        UIView * view = self.viewController.contentView;
        [self.bodyElement layout:view.bounds.size];
        [self.bodyElement obtainView:view];
        
    });
    
}

-(void) close {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_viewController respondsToSelector:@selector(KKWebViewBridgeClose:)]) {
            if([_viewController KKWebViewBridgeClose:self]) {
                return;
            }
        }
        
        if(self.viewController.navigationController) {
            [self.viewController.navigationController popViewControllerAnimated:YES];
        } else if(self.viewController.presentedViewController) {
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }
        
    });
    
}

-(void) style:(NSString *) name data:(NSDictionary *) data {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_viewController respondsToSelector:@selector(KKWebViewBridge:style:data:)]) {
            if([_viewController KKWebViewBridge:self style:name data:data]) {
                return ;
            }
        }
        if([name isEqualToString:@"topbar"]) {
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                if(v) {
                    self.viewController.navigationController.navigationBar.backgroundColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                if(v) {
                    self.viewController.navigationController.navigationBar.tintColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"bar-tint-color"]];
                if(v) {
                    self.viewController.navigationController.navigationBar.barTintColor = v;
                }
            }
            {
                id v = [data kk_getValue:@"hidden"];
                if(v) {
                    [self.viewController.navigationController setNavigationBarHidden:[v boolValue] animated:NO];
                    
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
                    self.viewController.view.tintColor = v;
                }
            }
        } else if([name isEqualToString:@"contentView"]) {
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"background-color"]];
                if(v) {
                    self.viewController.contentView.backgroundColor = v;
                }
            }
            {
                UIColor * v = [UIColor KKElementStringValue:[data kk_getString:@"tint-color"]];
                if(v) {
                    self.viewController.contentView.tintColor = v;
                }
            }
        }
    });
}

-(void) gesture:(NSDictionary *) gesture {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_viewController respondsToSelector:@selector(KKWebViewBridge:gesture:)]) {
            if([_viewController KKWebViewBridge:self gesture:gesture]) {
                return ;
            }
        }
        
        {
            id v = [gesture kk_getValue:@"back"];
            if(KKBooleanValue(v)) {
                self.viewController.navigationController.interactivePopGestureRecognizer.enabled = true;
            } else {
                self.viewController.navigationController.interactivePopGestureRecognizer.enabled = false;
            }
        }
        
    });
}

@end
