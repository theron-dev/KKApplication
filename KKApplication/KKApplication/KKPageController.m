//
//  KKPageController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKPageController.h"

static CGSize KKPageControllerViewSize(UIView * view) {
    
    CGSize size = view.bounds.size;
    
    if([view isKindOfClass:[UIScrollView class]]) {
        UIEdgeInsets edge = [(UIScrollView *) view contentInset];
        size.width -= edge.left + edge.right;
        size.height -= edge.top + edge.bottom;
    }
    
    return size;
}

@implementation KKPageController

@synthesize element = _element;
@synthesize elementNeedsLayoutDataKeys = _elementNeedsLayoutDataKeys;

-(void) dealloc {
    [_element recycleView];
}

-(void) run:(UIViewController *)viewController {
    [super run:viewController];
    
    __weak UIView * view = nil;
    
    if([viewController respondsToSelector:@selector(contentView)]) {
        view = [(id<KKViewController>) viewController contentView];
    } else {
        view = [viewController view];
    }
  
    [_element layout:KKPageControllerViewSize(view)];
    [_element obtainView:view];
    
    {
        //更新布局
        __weak KKPageController * v = self;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && view) {
                
                if([changedKeys count] ==0 ||
                   [[v elementNeedsLayoutDataKeys] containsObject:changedKeys[0]]) {
                    
                    [v.element layout:KKPageControllerViewSize(view)];
                    [v.element obtainView:view];
                }
                
            }
            
        } keys:@[] children:true priority:KKOBSERVER_PRIORITY_LOW context:nil];
        
    }
    
}

-(void) run {
    
    KKApplication * app = self.application;
    
    NSString * view = [self.path stringByAppendingString:@"_view.js"];
    
    if([app has:view]) {
        
        KKElement * e = [self.application elementWithPath:view observer:self.observer];
        
        if([e isKindOfClass:[KKViewElement class]]) {
            _element = (KKViewElement *) e;
            if([e isKindOfClass:[KKBodyElement class]]) {
                KKBodyElement * body = (KKBodyElement *) e;
                struct KKEdge padding = body.padding;
                CGFloat paddingTop = KKPixelValue(padding.top, 0, 0);
                CGFloat paddingBottom = KKPixelValue(padding.bottom, 0, 0);
                CGRect bounds =  [UIScreen mainScreen].bounds;
                if(bounds.size.height == 812.0) {
                    paddingTop += 24;
                    paddingBottom += 34;
                }
                padding.top.type = KKPixelTypePX;
                padding.top.value = paddingTop;
                padding.bottom.type = KKPixelTypePX;
                padding.bottom.value = paddingBottom;
                [body set:@"padding" value:NSStringFromKKEdge(padding)];
            }
        } else {
            _element = nil;
        }
        
    } else {
        NSLog(@"[KK] Not Found %@",[app absolutePath:view]);
    }
    
    [super run];
    
    {
        // 布局监听key
        NSArray * keys = [self.observer get:@[@"page",@"layoutKeys"] defaultValue:nil];
        if([keys isKindOfClass:[NSArray class]]) {
            self.elementNeedsLayoutDataKeys = [NSSet setWithArray:keys];
        }
    }

}

-(void) layout:(UIViewController *) viewController {
    
    UIView * view = nil;
    
    if([viewController respondsToSelector:@selector(contentView)]) {
        view = [(id<KKViewController>) viewController contentView];
    } else {
        view = [viewController view];
    }
    
    [_element layout:KKPageControllerViewSize(view)];
}

-(NSSet *) elementNeedsLayoutDataKeys {
    if(_elementNeedsLayoutDataKeys == nil) {
        _elementNeedsLayoutDataKeys = [NSSet setWithObjects:@"data", nil];
    }
    return _elementNeedsLayoutDataKeys;
}

-(void) recycle {
    [super recycle];
    [_element recycleView];
    [_element remove];
}

@end
