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
    UIStatusBarStyle _topbar_barStyle;
}

@end

@implementation KKController

@synthesize application = _application;
@synthesize http = _http;
@synthesize jsObserver = _jsObserver;
@synthesize query = _query;
@synthesize path = _path;

-(void) dealloc {
    [_http recycle];
    [_jsObserver recycle];
}

-(void) recycle {
    [_jsObserver recycle];
    [_http recycle];
    _http = nil;
    _jsObserver = nil;
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

-(KKJSObserver *) jsObserver {
    
    if(_jsObserver == nil) {
        KKObserver * v = [self.application newObserver];
        if(v == nil) {
            v = [[KKObserver alloc] init];
        }
        _jsObserver = [[KKJSObserver alloc] initWithObserver:v];
        
        [v set:@[@"page",@"landscape"] value:@(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))];
    }
    
    return _jsObserver;
}

-(KKObserver *) observer {
    return self.jsObserver.observer;
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
                                                   @"page":self.jsObserver,
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
            _topbar_hidden = [viewController kk_topbarHidden];
            [viewController setKk_topbarHidden:[v boolValue]];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        
        if(v) {
            
            UIImage * image = nil;
            
            if([v hasPrefix:@"#"]) {
                
                UIColor * color = [UIColor KKElementStringValue:[v kk_stringValue]];
                
                CGSize size = viewController.navigationController.navigationBar.bounds.size;
                UIGraphicsBeginImageContext(size);
                [color setFill];
                CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
                CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFill);
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsPopContext();
                
            } else {
                image = [self.application.viewContext imageWithURI:v];
            }
            
            _topbar_backgroundImage = [viewController kk_topbarBackgroundImage];
            _topbar_backgroundColor = [viewController kk_topbarBackgroundColor];
            
            [viewController setKk_topbarBackgroundImage:image];
            [viewController setKk_topbarBackgroundColor:[UIColor clearColor]];
            
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        
        if(v) {
            
            UIColor * color = [UIColor KKElementStringValue:[v kk_stringValue]];
            
            _topbar_backgroundColor = [viewController kk_topbarBackgroundColor];
            
            [viewController setKk_topbarBackgroundColor:color];
            
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
            _topbar_barStyle = [viewController kk_statusBarStyle];
            if([[v kk_stringValue] isEqualToString:@"light"]) {
                [viewController setKk_statusBarStyle:UIStatusBarStyleLightContent];
            } else {
                [viewController setKk_statusBarStyle:UIStatusBarStyleDefault];
            }
        }
    }
}

-(void) clearTopbarStyle:(UIViewController *) viewController {
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"hidden"] defaultValue:nil];
        if(v) {
            [viewController setKk_topbarHidden:_topbar_hidden];
        }
    }
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-image"] defaultValue:nil];
        if(v) {
            
            [viewController setKk_topbarBackgroundColor:_topbar_backgroundColor];
            [viewController setKk_topbarBackgroundImage:_topbar_backgroundImage];
            
        }
    }
    
    
    {
        id v = [self.observer get:@[@"page",@"topbar",@"background-color"] defaultValue:nil];
        if(v) {
            [viewController setKk_topbarBackgroundColor:_topbar_backgroundColor];
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
            [viewController setKk_statusBarStyle:_topbar_barStyle];
        }
    }
    
}

@end

@implementation UIViewController(KKController)

-(BOOL) kk_topbarHidden {
    return [self.navigationController isNavigationBarHidden];
}

-(void) setKk_topbarHidden:(BOOL)kk_topbarHidden {
    [self.navigationController setNavigationBarHidden:kk_topbarHidden animated:NO];
}

-(UIStatusBarStyle) kk_statusBarStyle {
    return [[UIApplication sharedApplication] statusBarStyle];
}

-(void) setKk_statusBarStyle:(UIStatusBarStyle)kk_statusBarStyle {
    [[UIApplication sharedApplication] setStatusBarStyle:kk_statusBarStyle animated:NO];
}

-(UIImage *) kk_topbarBackgroundImage {
    return [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
}

-(void) setKk_topbarBackgroundImage:(UIImage *)kk_topbarBackgroundImage {
    [self.navigationController.navigationBar setBackgroundImage:kk_topbarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setClipsToBounds:kk_topbarBackgroundImage != nil];
}

-(UIColor *) kk_topbarBackgroundColor {
    return [self.navigationController.navigationBar backgroundColor];
}

-(void) setKk_topbarBackgroundColor:(UIColor *)kk_topbarBackgroundColor {
    [self.navigationController.navigationBar setBackgroundColor:kk_topbarBackgroundColor];
}

@end
