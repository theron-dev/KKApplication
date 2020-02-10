//
//  KKPageController.m
//  KKApplication
//
//  Created by zhanghailong on 2017/12/30.
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

@synthesize document = _document;
@synthesize element = _element;
@synthesize elementNeedsLayoutDataKeys = _elementNeedsLayoutDataKeys;

-(void) dealloc {
    [_document recycle];
    [_element recycle];
}

-(void) setElementContentEdgeInsets:(UIEdgeInsets) edge {
    
    if([_element isKindOfClass:[KKBodyElement class]]) {
        
        KKBodyElement * body = (KKBodyElement *) _element;
        
        struct KKEdge padding = KKEdgeFromString([body get:@"padding"]);
        
        CGFloat paddingTop = KKPixelValue(padding.top, 0, 0) + edge.top;
        CGFloat paddingBottom = KKPixelValue(padding.bottom, 0, 0) + edge.bottom;
        CGFloat paddingLeft = KKPixelValue(padding.left, 0, 0) + edge.left;
        CGFloat paddingRight = KKPixelValue(padding.right, 0, 0) + + edge.right;
        
        
        padding.top.type = KKPixelTypePX;
        padding.top.value = paddingTop;
        padding.bottom.type = KKPixelTypePX;
        padding.bottom.value = paddingBottom;
        padding.left.type = KKPixelTypePX;
        padding.left.value = paddingLeft;
        padding.right.type = KKPixelTypePX;
        padding.right.value = paddingRight;
        body.padding = padding;
        
    }
    
}

-(void) runInView:(UIView *) inView edge:(UIEdgeInsets) edge {
    
    __weak UIView * view = inView;
    
    [self setElementContentEdgeInsets:edge];
    [_element layout:KKPageControllerViewSize(view)];
    [_element obtainView:view];
    
    if(_element) {
        
        __weak KKPageController * v = self;
        
        [_element on:@"layout" fn:^(KKEvent *event, void *context) {
            
            if(v && [event isKindOfClass:[KKElementEvent class]]) {
                
                NSDictionary * data = [(KKElementEvent *) event data];
                
                BOOL animated = [[data valueForKey:@"animated"] boolValue];
                
                if(animated) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.3];
                }
                
                [v.element layout:KKPageControllerViewSize(view)];
                [v.element obtainView:view];
                
                if(animated) {
                    [UIView commitAnimations];
                }
            }
            
        } context:nil];
        
    }
    
    {
        //更新布局
        __weak KKPageController * v = self;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && view) {
                
                if([changedKeys count] ==0 ||
                   [[v elementNeedsLayoutDataKeys] containsObject:changedKeys[0]]) {
                    
                    BOOL animated = NO;
                    
                    id data = [v.observer get:changedKeys defaultValue:nil];
                    
                    if([data isKindOfClass:[NSDictionary class]]) {
                        animated = KKBooleanValue([data kk_getValue:@"animated"]);
                    }
                    
                    if(animated) {
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:0.3];
                    }
                    
                    [v.element layout:KKPageControllerViewSize(view)];
                    [v.element obtainView:view];
                    
                    if(animated) {
                        [UIView commitAnimations];
                    }
                }
                
            }
            
        } keys:@[] children:true priority:KKOBSERVER_PRIORITY_LOW context:nil];
        
    }
    
    
}

-(UIEdgeInsets) elementScreenContentEdgeInsets {
    
    NSString * v = nil;
    
    if([_element isKindOfClass:[KKBodyElement class]]) {
        v = [_element get:@"edge"];
    }
    
    return [KKPageController screenContentEdgeInsetsWithEdge:v];
}

+(UIEdgeInsets) screenContentEdgeInsetsWithEdge:(NSString *) edge {
    
    UIEdgeInsets padding = UIEdgeInsetsZero;
    
    NSMutableSet * edgeSet = [NSMutableSet set];
    
    if(edge == nil) {
        [edgeSet addObject:@"top"];
        [edgeSet addObject:@"bottom"];
    } else {
        for(NSString * v in [edge componentsSeparatedByString:@" "]) {
            if([v length]) {
                [edgeSet addObject:v];
            }
        }
    }
    
    CGSize screenSize =  [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if(screenSize.height == 812.0 || screenSize.height == 896.0) {
        if([edgeSet containsObject:@"top"]) {
            padding.top += 24;
        }
        if([edgeSet containsObject:@"bottom"]) {
            padding.bottom += 34;
        }
    } else if(screenSize.width == 812.0 || screenSize.width == 896.0) {
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                if([edgeSet containsObject:@"top"]) {
                    padding.right += 24;
                }
                break;
            case UIInterfaceOrientationLandscapeRight:
                if([edgeSet containsObject:@"bottom"]) {
                    padding.left += 24;
                }
                break;
            default:
                break;
        }
    }
    
    return padding;
}

-(void) layoutInView:(UIView *) view edge:(UIEdgeInsets) edge {
    
    [self setElementContentEdgeInsets:edge];
    [_element layout:KKPageControllerViewSize(view)];

}


-(void) run:(UIViewController *)viewController {
    [super run:viewController];
    
    UIView * view = nil;
    
    if([viewController respondsToSelector:@selector(contentView)]) {
        view = [(id<KKViewController>) viewController contentView];
    } else {
        view = [viewController view];
    }
  
    [self runInView:view edge:[self elementScreenContentEdgeInsets]];
    
}

-(void) runLibrary:(NSMutableDictionary *) library {
    if(_document != nil) {
        [library setValue:_document forKey:@"document"];
    }
}

-(void) run {
    
    KKApplication * app = self.application;
    
    NSString * view = self.viewPath ;
    
    if(view == nil) {
        view = [self.path stringByAppendingString:@"_view.js"];
    } else {
        view = [view stringByAppendingString:@"_view.js"];
    }
    
    _document = [[KKPageDocument alloc] init];
    _document.viewContext = app.viewContext;
    
    if([app has:view]) {
        
        KKElement * e = [self.application elementWithPath:view data:self.jsObserver];
        
        if([e isKindOfClass:[KKViewElement class]]) {
            _element = (KKViewElement *) e;
        } else {
            _element = nil;
        }
        
        if(_element) {
            [_document setElement:_element forElementId:@"0"];
        } else {
            [_document create:@"body" elementId:@"0"];
            _element = (KKViewElement *) [_document elementById:@"0"];
        }
        
    } else {
        [_document create:@"body" elementId:@"0"];
        _element = (KKViewElement *) [_document elementById:@"0"];
    }
    
    CGRect bounds =  [UIScreen mainScreen].bounds;
    
    CGFloat height = MAX(bounds.size.width, bounds.size.height);
    
    if(height == 812.0) {
        [self.observer set:@[@"page",@"edge"] value:@{
                                                      @"top":@(24),
                                                      @"bottom":@(34),
                                                      @"left":@(0),
                                                      @"right":@(0)}];
    } else {
        [self.observer set:@[@"page",@"edge"] value:@{
                                                  @"top":@(0),
                                                  @"bottom":@(0),
                                                  @"left":@(0),
                                                  @"right":@(0)}];
    }
    
    [self.observer set:@[@"page",@"screen"] value:@{
                                                    @"width":@(bounds.size.width),
                                                    @"height":@(bounds.size.height)}];
    
    [super run];
    
    {
        // 布局监听key
        NSArray * keys = [self.observer get:@[@"page",@"layoutKeys"] defaultValue:nil];
        if([keys isKindOfClass:[NSArray class]]) {
            self.elementNeedsLayoutDataKeys = [NSSet setWithArray:keys];
        }
    }

}


-(void) installTopbar:(UIViewController *) viewController {
    
    KKElement * e = _element.firstChild;
    
    if(e && [e isKindOfClass:[KKTopbarElement class]]){
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = 64;
        CGFloat paddingTop = 20;
        
        if(screenSize.height == 812.0) {
            height += 24;
            paddingTop += 24;
        }
        
        KKElement * p = e.firstChild;
        
        while(p) {
            
            if([p isKindOfClass:[KKViewElement class]]) {
                
                KKElementView * elementView = nil;
                
                NSString * target = [p get:@"target"];
                
                if([target isEqualToString:@"left"]) {
                    elementView = [[KKElementView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width * 0.2, height - paddingTop)];
                    elementView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
                    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:elementView];
                }
                else if([target isEqualToString:@"center"]) {
                    elementView = [[KKElementView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width * 0.8, height - paddingTop)];
                    elementView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                    viewController.navigationItem.titleView = elementView;
                }
                else if([target isEqualToString:@"right"]) {
                    elementView = [[KKElementView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width * 0.2, height - paddingTop)];
                    elementView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
                    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:elementView];
                }
                
                elementView.element = (KKViewElement *) p;
                
            }
            
            p = p.nextSibling;
        }
    }
    
}

-(void) layoutTopbar:(UIViewController *) viewController {
    
    
}

-(void) layout:(UIViewController *) viewController {
    
    UIView * view = nil;
    
    if([viewController respondsToSelector:@selector(contentView)]) {
        view = [(id<KKViewController>) viewController contentView];
    } else {
        view = [viewController view];
    }
    
    [self layoutInView:view edge:[self elementScreenContentEdgeInsets]];

}

-(NSSet *) elementNeedsLayoutDataKeys {
    if(_elementNeedsLayoutDataKeys == nil) {
        _elementNeedsLayoutDataKeys = [NSSet setWithObjects:@"data", nil];
    }
    return _elementNeedsLayoutDataKeys;
}

-(void) recycle {
    [super recycle];
    [_document recycle];
    [_element recycle];
    [_element remove];
}

@end
