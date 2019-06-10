//
//  KKPageElement.m
//  KKApplication
//
//  Created by zhanghailong on 2018/9/4.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKPageElement.h"
#import "KKPageController.h"

@interface KKPageElement() {
    
}

@property(nonatomic,strong) KKPageController * pageController;
@property(nonatomic,assign) BOOL pageShowing;

@end

@implementation KKPageElement


-(KKApplication *) app {
    KKApplication * app = (KKApplication *) self.viewContext.delegate;
    if([app isKindOfClass:[KKApplication class]]) {
        return app;
    }
    return nil;
}

-(instancetype) init {
    if((self = [super init])) {
        [self setAttrs:@{@"hidden":@"true"}];
    }
    return self;
}

+(void) initialize {
    [KKViewContext setDefaultElementClass:[KKPageElement class] name:@"page"];
}

-(void) dealloc {
    [_pageController recycle];
}

-(void) recycle {
    [_pageController recycle];
    _pageController = nil;
    [super recycle];
}

-(void) showPage {
    
    UIView * view = self.view;
    
    if(view == nil) {
        return ;
    }
    
    if(!_pageShowing && _pageController) {
        _pageShowing = YES;
        [_pageController willAppear];
        UIView * v = [[_pageController element] view];
        if(v && v != view && v.superview != view) {
            [view addSubview:v];
        }
        [_pageController didAppear];
    }
    
}

-(void) hidePage {
    
    UIView * view = self.view;
    
    if(view == nil) {
        return ;
    }
    
    if(_pageShowing && _pageController) {
        _pageShowing = NO;
        [_pageController willDisappear];
        UIView * v = [[_pageController element] view];
        if(v && v != view && v.superview == view) {
            [v removeFromSuperview];
        }
        [_pageController didDisappear];
    }
}

-(void) open {
    
    UIView * view = self.view;
    
    if(view == nil) {
        return ;
    }
    
    NSString * path = [self get:@"path"];
    
    if(_pageController && [_pageController.path isEqualToString:path]) {
        if([self isHidden]) {
            [self hidePage];
        } else {
            [self showPage];
        }
        return;
    }
    
    if(_pageController) {
        if(_pageShowing) {
            [_pageController willDisappear];
            [_pageController didDisappear];
        }
        [_pageController recycle];
        _pageController = nil;
    }
    
    if([path length] == 0) {
        return ;
    }
    
    if([self isHidden]) {
        [self hidePage];
        return ;
    }
    
    KKApplication * app = [self app];
    
    if(app == nil) {
        return;
    }
    
    _pageController = [[KKPageController alloc] init];
    _pageController.application = app;
    [_pageController setQuery:self.data];
    [_pageController setPath:path];
    [_pageController setViewPath:[self get:@"view"]];
    [_pageController run];
    
    [_pageController runInView:view edge:UIEdgeInsetsMake(-20, 0, 0, 0)];
    
    [_pageController willAppear];
    [_pageController didAppear];
    
    _pageShowing = YES;
}

-(void) setView:(UIView *)view {
    if(_pageController) {
        [_pageController willDisappear];
        [_pageController didDisappear];
        [_pageController recycle];
        _pageController = nil;
    }
    [super setView:view];
    if(view) {
        __weak KKPageElement * element = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [element open];
        });
    }
}

-(void) changedKey:(NSString *)key {
    [super changedKey:key];
    
    if([key isEqualToString:@"hidden"] || [key isEqualToString:@"path"]) {
        [self open];
    }
    
}

-(void) didLayouted {
    [super didLayouted];
    
    UIView * view = self.view;
    
    if(view == nil) {
        return ;
    }
    
    if(_pageController) {
        [_pageController layoutInView:view edge:UIEdgeInsetsMake(-20, 0, 0, 0)];
    }
    
}

@end
