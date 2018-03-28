//
//  KKApp.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKApp.h"

#import "KKPageViewController.h"
#import "KKWebViewController.h"
#import "KKWindowPageController.h"
#import "KKNavigationController.h"

#import <CommonCrypto/CommonCrypto.h>

static unsigned char require_js[] = {0xa,0x28,0x66,0x75,0x6e,0x63,0x74,0x69,0x6f,0x6e,0x28,0x6b,0x6b,0x29,0x7b,0xa,0x9,0x76,0x61,0x72,0x20,0x6d,0x6f,0x64,0x75,0x6c,0x65,0x73,0x20,0x3d,0x20,0x7b,0x7d,0x3b,0xa,0x9,0x6b,0x6b,0x2e,0x72,0x65,0x71,0x75,0x69,0x72,0x65,0x20,0x3d,0x20,0x66,0x75,0x6e,0x63,0x74,0x69,0x6f,0x6e,0x28,0x70,0x61,0x74,0x68,0x29,0x20,0x7b,0xa,0x9,0x9,0x76,0x61,0x72,0x20,0x6d,0x20,0x3d,0x20,0x6d,0x6f,0x64,0x75,0x6c,0x65,0x73,0x5b,0x70,0x61,0x74,0x68,0x5d,0x3b,0xa,0x9,0x9,0x69,0x66,0x28,0x6d,0x20,0x3d,0x3d,0x3d,0x20,0x75,0x6e,0x64,0x65,0x66,0x69,0x6e,0x65,0x64,0x29,0x20,0x7b,0xa,0x9,0x9,0x9,0x6d,0x20,0x3d,0x20,0x7b,0x20,0x65,0x78,0x70,0x6f,0x72,0x74,0x73,0x20,0x3a,0x20,0x7b,0x7d,0x20,0x7d,0x3b,0xa,0x9,0x9,0x9,0x74,0x72,0x79,0x20,0x7b,0xa,0x9,0x9,0x9,0x9,0x76,0x61,0x72,0x20,0x63,0x6f,0x64,0x65,0x20,0x3d,0x20,0x6b,0x6b,0x2e,0x67,0x65,0x74,0x53,0x74,0x72,0x69,0x6e,0x67,0x28,0x70,0x61,0x74,0x68,0x29,0x3b,0xa,0x9,0x9,0x9,0x9,0x76,0x61,0x72,0x20,0x66,0x6e,0x20,0x3d,0x20,0x65,0x76,0x61,0x6c,0x28,0x22,0x28,0x66,0x75,0x6e,0x63,0x74,0x69,0x6f,0x6e,0x28,0x6d,0x6f,0x64,0x75,0x6c,0x65,0x2c,0x65,0x78,0x70,0x6f,0x72,0x74,0x73,0x29,0x7b,0x22,0x20,0x2b,0x20,0x63,0x6f,0x64,0x65,0x20,0x2b,0x20,0x22,0x7d,0x29,0x22,0x29,0x3b,0xa,0x9,0x9,0x9,0x9,0x69,0x66,0x28,0x74,0x79,0x70,0x65,0x6f,0x66,0x20,0x66,0x6e,0x20,0x3d,0x3d,0x20,0x27,0x66,0x75,0x6e,0x63,0x74,0x69,0x6f,0x6e,0x27,0x29,0x20,0x7b,0xa,0x9,0x9,0x9,0x9,0x9,0x66,0x6e,0x28,0x6d,0x2c,0x6d,0x2e,0x65,0x78,0x70,0x6f,0x72,0x74,0x73,0x29,0x3b,0xa,0x9,0x9,0x9,0x9,0x7d,0xa,0x9,0x9,0x9,0x9,0x70,0x72,0x69,0x6e,0x74,0x28,0x22,0x72,0x65,0x71,0x75,0x69,0x72,0x65,0x20,0x22,0x20,0x2b,0x20,0x70,0x61,0x74,0x68,0x29,0x3b,0xa,0x9,0x9,0x9,0x7d,0x20,0x63,0x61,0x74,0x63,0x68,0x28,0x65,0x29,0x20,0x7b,0xa,0x9,0x9,0x9,0x9,0x70,0x72,0x69,0x6e,0x74,0x28,0x65,0x2e,0x74,0x6f,0x53,0x74,0x72,0x69,0x6e,0x67,0x28,0x29,0x29,0x3b,0xa,0x9,0x9,0x9,0x7d,0xa,0x9,0x9,0x9,0x6d,0x6f,0x64,0x75,0x6c,0x65,0x73,0x5b,0x70,0x61,0x74,0x68,0x5d,0x20,0x3d,0x20,0x6d,0x3b,0xa,0x9,0x9,0x7d,0xa,0x9,0x9,0x72,0x65,0x74,0x75,0x72,0x6e,0x20,0x6d,0x2e,0x65,0x78,0x70,0x6f,0x72,0x74,0x73,0x3b,0xa,0x9,0x7d,0x3b,0xa,0x7d,0x29,0x28,0x6b,0x6b,0x29,0x3b,0xa,0x00};

@implementation KKApplication

@synthesize jsObserver = _jsObserver;

-(instancetype) initWithBundle:(NSBundle *) bundle {
    return [self initWithBundle:bundle jsContext:[[JSContext alloc] init]];
}

-(instancetype) initWithBundle:(NSBundle *) bundle jsContext:(JSContext *) jsContext {
    if((self = [super init])) {
        _jsObserver = [[KKJSObserver alloc] initWithObserver:[[KKObserver alloc] initWithJSContext:jsContext]];
        _bundle = bundle;
        _viewContext = [[KKViewContext alloc] init];
        [_viewContext setBasePath:self.path];
        _viewContext.delegate = self;
        
        [jsContext KKViewOpenlib];
        
        __weak KKApplication * app = self;
        
        {
            JSValue * kk = [JSValue valueWithNewObjectInContext:jsContext];
            
            [kk setValue:@(KKApplicationKernel) forProperty:@"kernel"];
            [kk setValue:@"ios" forProperty:@"platform"];
            
            [kk setValue:^NSString *(NSString *path){

                return [NSString stringWithContentsOfFile:[app absolutePath:path] encoding:NSUTF8StringEncoding error:nil];
                
            } forProperty:@"getString"];
            
            {
                JSValue * app = [JSValue valueWithNewObjectInContext:jsContext];
            
                NSBundle * main = [NSBundle mainBundle];
                [app setValue:[[main infoDictionary] valueForKey:@"CFBundleIdentifier"] forProperty:@"id"];
                [app setValue:[[main infoDictionary] valueForKey:@"CFBundleShortVersionString"] forProperty:@"version"];
                [app setValue:[[main infoDictionary] valueForKey:@"CFBundleVersion"] forProperty:@"build"];
                [app setValue:[[main infoDictionary] valueForKey:@"CFBundleDisplayName"] forProperty:@"name"];
                [app setValue:[[NSLocale currentLocale] localeIdentifier] forProperty:@"lang"];
                
                [kk setValue:app forProperty:@"app"];
            }
            
            {
                JSValue * v = [JSValue valueWithNewObjectInContext:jsContext];
                
                UIDevice * device = [UIDevice currentDevice];
                
                CC_MD5_CTX m;
                
                CC_MD5_Init(&m);
                
                NSData * data = [[[device identifierForVendor] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
                
                CC_MD5_Update(&m, [data bytes], (CC_LONG) [data length]);
                
                unsigned char md[16];
                
                CC_MD5_Final(md, &m);
                
                [v setValue:[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
                               ,md[0],md[1],md[2],md[3],md[4],md[5],md[6],md[7]
                               ,md[8],md[9],md[10],md[11],md[12],md[13],md[14],md[15]] forProperty:@"id"];
                [v setValue:[device systemName] forProperty:@"systemName"];
                [v setValue:[device systemVersion] forProperty:@"systemVersion"];
                [v setValue:[device model] forProperty:@"model"];
                [v setValue:[device name] forProperty:@"name"];
                
                [kk setValue:v forProperty:@"device"];
            }
            
            [[jsContext globalObject] setValue:kk forProperty:@"kk"];
            
        }
        
        {
            [jsContext evaluateScript:[NSString stringWithCString:(char *) require_js encoding:NSUTF8StringEncoding]];
        }
        
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(app && [value isKindOfClass:[NSDictionary class]]) {
                
                [app doAction:value];
                
            }
            
        } keys:@[@"action",@"open"] context:nil];
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(app && value) {
                
                [[[UIAlertView alloc] initWithTitle:nil message:KKStringValue(value)
                                           delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                
            }
            
        } keys:@[@"alert"] context:nil];
        
    }
    return self;
}

-(void) dealloc {
    [_jsObserver recycle];
}

-(KKObserver *) observer {
    return _jsObserver.observer;
}

-(KKElement *) elementWithPath:(NSString *) path observer:(KKJSObserver *) observer{
    
    KKElement * rootElement = [[KKElement alloc] init];
    
    if(_viewContext) {
        [KKViewContext pushContext:_viewContext];
    }
    
    NSString * code = [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:nil];
    
    JSValue * fn = [self.jsContext evaluateScript:[NSString stringWithFormat:@"(function(element,data){ %@ })",code]];
    
    [fn callWithArguments:@[rootElement,observer]];
    
    if(_viewContext) {
        [KKViewContext popContext];
    }
    
    return rootElement.lastChild;
}

-(NSString *) path {
    return [_bundle bundlePath];
}

-(void) openlib:(NSString *) path {
    
    NSString * v = [self.path stringByAppendingPathComponent:path];
    NSString * code = [NSString stringWithContentsOfFile:v encoding:NSUTF8StringEncoding error:nil];
    
    if(code) {
        [self.jsContext evaluateScript:code];
    }
    
}

-(void) exec:(NSString *) path librarys:(NSDictionary *)librarys {
    
    NSString * v = [self.path stringByAppendingPathComponent:path];
    NSString * code = [NSString stringWithContentsOfFile:v encoding:NSUTF8StringEncoding error:nil];
    
    if(code) {
        
        NSMutableDictionary * libs = [NSMutableDictionary dictionaryWithCapacity:4];
        
        if(librarys != nil) {
            [libs addEntriesFromDictionary:librarys];
        }
        
        libs[@"app"] = self.jsObserver;
        
        NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:4];
        
        NSMutableString * execCode = [[NSMutableString alloc] initWithCapacity:128];
        
        [execCode appendString:@"(function("];
        
        NSEnumerator * keyEnum = [libs keyEnumerator];
        NSString * key;
        
        while((key = [keyEnum nextObject])) {
            if([arguments count] != 0) {
                [execCode appendString:@","];
            }
            [execCode appendString:key];
            [arguments addObject:[libs valueForKey:key]];
        }
        
        [execCode appendFormat:@"){%@})",code];
        
        JSValue * fn = [self.jsContext evaluateScript:execCode];
        
        [fn callWithArguments:arguments];
        
    } else {
        NSLog(@"[KK] Not Found %@",v);
    }
    
}

-(KKObserver *) newObserver {
    return [[KKObserver alloc] initWithJSContext:self.jsContext];
}

-(NSString *) absolutePath:(NSString *) path {
    return [self.path stringByAppendingPathComponent:path];
}

-(BOOL) has:(NSString *) path {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path]];
}

-(JSContext *) jsContext {
    return [self.observer jsContext];
}

-(UITabBarController *) openTabBarController:(NSDictionary *) action {
    
    UITabBarController * tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:self.bundle];
    
    NSMutableArray * viewControllers = [NSMutableArray arrayWithCapacity:4];
    
    UIViewController * selectedViewController = nil;
    
    NSArray * items = [action kk_getValue:@"items"];
    
    if([items isKindOfClass:[NSArray class]]) {
        
        for(NSDictionary * item in items) {
            
            if([item isKindOfClass:[NSDictionary class]]) {
                
                UIViewController * viewController = [self openViewController:item];
                
                KKNavigationController * navController = [[KKNavigationController alloc] initWithRootViewController:viewController];
                
                id tabbar = [item kk_getValue:@"tabbar"];
                
                UIImage * image = [self.viewContext imageWithURI:[tabbar kk_getString:@"image"]];
                UIImage * selectedImage = [self.viewContext imageWithURI:[tabbar kk_getString:@"image:selected"]];
                
                if(image && selectedImage) {
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                }
                
                NSString * title = [tabbar kk_getString:@"title"];
                
                navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
                
                [viewControllers addObject:navController];
                
                if([[tabbar kk_getValue:@"selected"] boolValue]) {
                    selectedViewController = navController;
                }
            }
            
        }
    }
    
    tabBarController.viewControllers = viewControllers;
    
    if(selectedViewController) {
        tabBarController.selectedViewController = selectedViewController;
    }
    
    {
        __weak UITabBarController * v = tabBarController;
        
        [self.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(v && value) {
                NSInteger i = [value integerValue];
                if(i >=0 && i < [v.viewControllers count]) {
                    v.selectedIndex = i;
                }
            }
            
        } keys:@[@"tabbar",@"selected"] context:nil];
        
    }
    
    id tabbar = [action kk_getValue:@"tabbar"];
    {
        UIColor * v = [UIColor KKElementStringValue:[tabbar kk_getString:@"background-color"]];
        if(v) {
            tabBarController.tabBar.backgroundColor = v;
        }
    }
    
    {
        UIColor * v = [UIColor KKElementStringValue:[tabbar kk_getString:@"tint-color"]];
        if(v) {
            tabBarController.tabBar.tintColor = v;
        }
    }
    
    {
        UIColor * v = [UIColor KKElementStringValue:[tabbar kk_getString:@"color"]];
        if(v) {
            tabBarController.tabBar.barTintColor = v;
        }
    }
    
    {
        UIColor * v = [UIColor KKElementStringValue:[action kk_getString:@"background-color"]];
        if(v) {
            tabBarController.view.backgroundColor = v;
        }
    }
    
    {
        UIColor * v = [UIColor KKElementStringValue:[action kk_getString:@"tint-color"]];
        if(v) {
            tabBarController.view.tintColor = v;
        }
    }
    
    return tabBarController;
}

-(UIViewController *) openViewController:(NSDictionary *) action {
    
    UIViewController * viewController = nil;
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:viewController:)]) {
        viewController = [_delegate KKApplication:self viewController:action];
    }
    
    if(viewController == nil) {
        
        Class isa = NSClassFromString([action valueForKey:@"class"]);
        
        if(isa == nil && [action kk_getString:@"url"]) {
            isa = [KKWebViewController class];
        }
        
        if(isa == nil && [action kk_getString:@"scheme"]) {
            NSString * v = [action kk_getString:@"scheme"];
            if([v hasPrefix:@"http://"] || [v hasPrefix:@"https://"]) {
                isa = [KKWebViewController class];
            } else {
                return nil;
            }
        }
        
        if(isa ==nil && [[action kk_getString:@"type"] isEqualToString:@"tabbar"]) {
            return [self openTabBarController:action];
        }

        if(isa == nil && [action kk_getString:@"path"]) {
            isa = [KKPageViewController class];
        }
        
        if(isa == nil) {
            NSLog(@"Not Implement Action %@",action);
            return nil;
        }
        
        viewController = [[isa alloc] initWithNibName:[action valueForKey:@"nibName"] bundle:self.bundle];
        
    }
    
    viewController.title = [action valueForKey:@"title"];
    
    if([viewController conformsToProtocol:@protocol(KKViewController)]) {
        id<KKViewController>  kkViewController = (id<KKViewController>) viewController;
        kkViewController.application = self;
        kkViewController.action = action;
    }
    
    return viewController;
}

-(KKWindowPageController *) openWindowPageController:(NSDictionary *) action {
    
    KKWindowPageController * pageController = [[KKWindowPageController alloc] init];
    
    pageController.application = self;
    pageController.action = action;
    
    [pageController show];
    
    return pageController;
}

-(void) doAction:(NSDictionary *) action {
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:openAction:)]) {
        if([_delegate KKApplication:self openAction:action]) {
            return;
        }
    }
    
    if([[action kk_getString:@"type"] isEqualToString:@"window"]) {
        [self openWindowPageController:action];
        return ;
    }
    
    UIViewController * viewController = [self openViewController:action];
    
    if(viewController == nil) {
        
        if([action kk_getString:@"scheme"]) {
            NSString * v = [action kk_getString:@"scheme"];
            if(![v hasPrefix:@"http://"] && ![v hasPrefix:@"https://"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:v]];
                return;
            }
        }
        
        return ;
    }
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:openViewController:action:)]) {
        if([_delegate KKApplication:self openViewController:viewController action:action]) {
            return;
        }
    }
    
    UIViewController * topViewController = [KKApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    if(topViewController == nil
       || [[action kk_getString:@"target"] isEqualToString:@"root"]) {
        
        if([viewController isKindOfClass:[UITabBarController class]] || [viewController isKindOfClass:[UINavigationController class]]) {
            [[UIApplication sharedApplication].keyWindow setRootViewController:viewController];
        } else if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[UINavigationController class]]){
            [(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController setViewControllers:@[viewController] animated:NO];
        } else {
            [[UIApplication sharedApplication].keyWindow setRootViewController:[[KKNavigationController alloc] initWithRootViewController:viewController]];
        }
        
    }
    else if([topViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *) topViewController pushViewController:viewController animated:YES];
    } else {
        [topViewController presentViewController:viewController animated:YES completion:nil];
    }
}

+(UIViewController *) topViewController:(UIViewController *) viewController {
    
    if([viewController isKindOfClass:[UINavigationController class]]) {
        return viewController;
    }
    
    if([viewController isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *) viewController selectedViewController]];
    }
    
    if(viewController.presentedViewController) {
        return viewController.presentedViewController;
    }
    
    return viewController;
}

-(void) run {
    [self exec:@"main.js" librarys:nil];
}

-(void) KKViewContext:(KKViewContext *)viewContext willSend:(KKHttpOptions *)options {
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:willSend:)]) {
        [_delegate KKApplication:self willSend:options];
    }
    
}

-(id<KKHttpTask>) KKViewContext:(KKViewContext *) viewContext send:(KKHttpOptions *) options weakObject:(id) weakObject {
    
    if([(id)_delegate respondsToSelector:@selector(KKApplication:send:weakObject:)]) {
        return [_delegate KKApplication:self send:options weakObject:weakObject];
    }

    return nil;
}

-(BOOL) KKViewContext:(KKViewContext *) viewContext cancel:(id) weakObject {
    
    if([(id)_delegate respondsToSelector:@selector(KKApplication:cancel:)]) {
        return [_delegate KKApplication:self cancel:weakObject];
    }
    
    return NO;
}

-(UIImage *) KKViewContext:(KKViewContext *) viewContext imageWithURI:(NSString * ) uri {
    
    if([(id)_delegate respondsToSelector:@selector(KKApplication:imageWithURI:)]) {
        return [_delegate KKApplication:self imageWithURI:uri];
    }
    
    return nil;
}

-(void) recycle {
    [_jsObserver recycle];
    _jsObserver = nil;
}

+(instancetype) main {
    static KKApplication * v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[KKApplication alloc] initWithBundle:[NSBundle mainBundle]];
    });
    return v;
}

@end

@implementation UIApplication (KKApplication)

-(KKApplication *) KKApplication {
    
    UIViewController * viewController = [[self keyWindow] rootViewController];
    
    if([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = [[(UINavigationController *) viewController viewControllers] firstObject];
    } else if([viewController isKindOfClass:[UITabBarController class]]) {
        viewController = [[(UITabBarController *) viewController viewControllers] firstObject];
    }
    
    if([viewController conformsToProtocol:@protocol(KKViewController)]) {
        return [(id<KKViewController>) viewController application];
    }
    
    return nil;
}

-(UIViewController *) kk_topViewController {
    return [KKApplication topViewController:self.keyWindow.rootViewController];
}

@end
