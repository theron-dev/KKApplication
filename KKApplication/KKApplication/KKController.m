//
//  KKController.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/30.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKController.h"

@interface KKController() {
    BOOL _topbar_hidden;
    UIColor * _topbar_tintColor;
    UIColor * _topbar_barTintColor;
    UIColor * _topbar_backgroundColor;
    UIImage * _topbar_backgroundImage;
    UIBarStyle _topbar_barStyle;
}

@end

@implementation KKController

@synthesize application = _application;
@synthesize http = _http;
@synthesize observer = _observer;
@synthesize query = _query;
@synthesize path = _path;

-(void) dealloc {
    [_http cancel];
    [_observer off:nil keys:@[] context:nil];
}

-(void) recycle {
    [_http cancel];
    [_observer off:nil keys:@[] context:nil];
}

-(KKJSHttp *) http {
    
    if(_http == nil) {
        id<KKHttp> http = [self.application viewContext];
        if(http == nil) {
            http = [KKHttp main];
        }
        _http = [[KKJSHttp alloc] initWithHttp:http];
    }
    
    return _http;
}

-(KKObserver *) observer {
    
    if(_observer == nil) {
        _observer = [self.application newObserver];
    }
    
    if(_observer == nil) {
        _observer = [[KKObserver alloc] init];
    }
    
    return _observer;
}

-(NSDictionary *) query {
    if(_query == nil) {
        _query = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _query;
}


-(void) run {
    
    KKApplication * app = self.application;
    NSString * main = [self.path stringByAppendingString:@".js"];
    
    if(main != nil) {
        
        if([app has:main]) {
            
            [self.application exec:main librarys:@{
                                                   @"http":self.http,
                                                   @"page":self.observer,
                                                   @"query":self.query,
                                                   @"path":self.path}];
            
        } else {
            NSLog(@"[KK] Not Found %@",[app absolutePath:main]);
        }
        
    }
    
}


-(void) run:(UIViewController *) viewController {
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && value) {
                
                v.view.backgroundColor = [UIColor KKElementStringValue:[value kk_stringValue]];
                
            }
            
        } keys:@[@"page",@"background-color"] context:nil];
        
    }
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && value) {
                
                v.view.tintColor = [UIColor KKElementStringValue:[value kk_stringValue]];
                
            }
            
        } keys:@[@"page",@"tint-color"] context:nil];
        
    }
    
    {
        __weak UIViewController * v = viewController;
        
        [self.observer on:^(id title, NSArray *changedKeys, void *context) {
            
            if(v && title) {
                
                v.title = [title kk_stringValue];
                
            }
            
        } keys:@[@"page",@"title"] context:nil];
        
    }
    
    [self run];
    
    viewController.hidesBottomBarWhenPushed = [[self.observer get:@[@"page",@"bottombar",@"hidden"] defaultValue:@(true)] boolValue];

}


-(void) willAppear {
    [self.observer changeKeys:@[@"page",@"willAppear"]];
}

-(void) didAppear {
    [self.observer changeKeys:@[@"page",@"didAppear"]];
}

-(void) willDisappear {
    [self.observer changeKeys:@[@"page",@"willDisappear"]];
}

-(void) didDisappear {
    [self.observer changeKeys:@[@"page",@"didDisappear"]];
}

-(void) setTopbarStyle:(UIViewController *) viewController {
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            _topbar_hidden = [viewController.navigationController isNavigationBarHidden];
            [viewController.navigationController setNavigationBarHidden:[v boolValue] animated:NO];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        if(v) {
            
            UIImage * image = [self.application.viewContext imageWithURI:v];
            
            _topbar_backgroundImage = [viewController.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
            
            [viewController.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            
            if(image) {
                [viewController.navigationController.navigationBar setClipsToBounds:YES];
            }
            
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        
        if(v) {
            
            UIColor * color = [UIColor KKElementStringValue:[v kk_stringValue]];
            _topbar_backgroundColor = [viewController.navigationController.navigationBar backgroundColor];
            _topbar_backgroundImage = [viewController.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
            
            CGSize size = viewController.navigationController.navigationBar.bounds.size;
            UIGraphicsBeginImageContext(size);
            [color setFill];
            CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
            CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFill);
            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsPopContext();
            
            [viewController.navigationController.navigationBar setBackgroundColor:color];
            [viewController.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            
            if(image) {
                [viewController.navigationController.navigationBar setClipsToBounds:YES];
            }
            
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            _topbar_tintColor = [viewController.navigationController.navigationBar tintColor];
            [viewController.navigationController.navigationBar setTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            _topbar_barTintColor = [viewController.navigationController.navigationBar barTintColor];
            [viewController.navigationController.navigationBar setBarTintColor:[UIColor KKElementStringValue:[v kk_stringValue]]];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"style"] defaultValue:nil];
        if(v) {
            _topbar_barStyle = [viewController.navigationController.navigationBar barStyle];
            if([[v kk_stringValue] isEqualToString:@"light"]) {
                [viewController.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
            } else {
                [viewController.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
            }
        }
    }
}

-(void) clearTopbarStyle:(UIViewController *) viewController {
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            [viewController.navigationController setNavigationBarHidden:_topbar_hidden animated:NO];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        if(v) {
            
            [viewController.navigationController.navigationBar setBackgroundImage:_topbar_backgroundImage forBarMetrics:UIBarMetricsDefault];
            
            [viewController.navigationController.navigationBar setClipsToBounds:_topbar_backgroundImage != nil];
            
        }
    }
    
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            
            [viewController.navigationController.navigationBar setBackgroundColor:_topbar_backgroundColor];
            [viewController.navigationController.navigationBar setBackgroundImage:_topbar_backgroundImage forBarMetrics:UIBarMetricsDefault];
            
            [viewController.navigationController.navigationBar setClipsToBounds:_topbar_backgroundImage != nil];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"tint-color"] defaultValue:nil];
        if(v) {
            [viewController.navigationController.navigationBar setTintColor:_topbar_tintColor];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"bar-tint-color"] defaultValue:nil];
        if(v) {
            [viewController.navigationController.navigationBar setBarTintColor:_topbar_barTintColor];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"style"] defaultValue:nil];
        if(v) {
            [viewController.navigationController.navigationBar setBarStyle:_topbar_barStyle];
        }
    }
    
}

@end
