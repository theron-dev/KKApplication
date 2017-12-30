//
//  KKPageController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKPageController.h"

@implementation KKPageController

@synthesize element = _element;
@synthesize elementNeedsLayoutDataKeys = _elementNeedsLayoutDataKeys;

-(void) run:(UIViewController *)viewController {
    [super run:viewController];
    
    [_element layout:viewController.view.bounds.size];
    [_element obtainView:viewController.view];
    
    {
        //更新布局
        __weak KKPageController * v = self;
        __weak UIViewController * ctl = viewController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v) {
                
                if([changedKeys count] ==0 ||
                   [[v elementNeedsLayoutDataKeys] containsObject:changedKeys[0]]) {
                    
                    [v.element layout:ctl.view.bounds.size];
                    [v.element obtainView:ctl.view];
                }
                
            }
            
        } keys:@[] children:true identity:INT_MAX context:nil];
        
    }
    
}

-(void) run {
    
    KKApplication * app = self.application;
    
    NSString * view = [self.path stringByAppendingString:@"_view.js"];
    
    if([app has:view]) {
        
        KKElement * e = [self.application elementWithPath:view observer:self.observer];
        
        if([e isKindOfClass:[KKViewElement class]]) {
            _element = (KKViewElement *) e;
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
    [self.element layout:viewController.view.bounds.size];
}

-(NSSet *) elementNeedsLayoutDataKeys {
    if(_elementNeedsLayoutDataKeys == nil) {
        _elementNeedsLayoutDataKeys = [NSSet setWithObjects:@"data", nil];
    }
    return _elementNeedsLayoutDataKeys;
}


@end
