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

@implementation KKApplication

+(double) version {
    return KKApplicationVersion;
}

+(unsigned int) build {
    return KKApplicationBuild;
}

-(instancetype) initWithBundle:(NSBundle *) bundle {
    return [self initWithBundle:bundle jsContext:[[JSContext alloc] init]];
}

-(instancetype) initWithBundle:(NSBundle *) bundle jsContext:(JSContext *) jsContext {
    if((self = [super init])) {
        _observer = [[KKObserver alloc] initWithJSContext:jsContext];
        _bundle = bundle;
        _viewContext = [[KKViewContext alloc] init];
        [_viewContext setBasePath:self.path];
        _viewContext.delegate = self;
        
        [jsContext KKViewOpenlib];
        
        __weak KKApplication * app = self;
        
        {
            JSValue * kk = [JSValue valueWithNewObjectInContext:jsContext];
            
            [kk setValue:^NSString *(NSString *path){

                return [NSString stringWithContentsOfFile:[app absolutePath:path] encoding:NSUTF8StringEncoding error:nil];
                
            } forProperty:@"getString"];
            
            [[jsContext globalObject] setValue:kk forProperty:@"kk"];
            
        }
        
        [_observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(app && [value isKindOfClass:[NSDictionary class]]) {
                
                [app doAction:value];
                
            }
            
        } keys:@[@"action",@"open"] context:nil];
        
    }
    return self;
}

-(void) dealloc {
    [_observer off:nil keys:@[] context:nil];
}


-(KKElement *) elementWithPath:(NSString *) path observer:(KKObserver *) observer {
    
    if(_viewContext) {
        [KKViewContext pushContext:_viewContext];
    }
    
    KKElement * root = [[KKElement alloc] init];
    
    {
        NSString * code = [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:nil];
        
        JSValue * fn = [self.jsContext evaluateScript:[NSString stringWithFormat:@"(function(element,data){ %@ })",code]];
        
        [fn callWithArguments:@[root,observer]];
        
    }
    
    if(_viewContext) {
        [KKViewContext popContext];
    }
    
    return root.firstChild;
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
        
        libs[@"app"] = self.observer;
        
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
    return [_observer jsContext];
}

-(void) doAction:(NSDictionary *) action {
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:openAction:)]) {
        if([_delegate KKApplication:self openAction:action]) {
            return;
        }
    }
    
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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:v]];
                return;
            }
        }
        
        if(isa == nil && [action kk_getString:@"path"]) {
            isa = [KKPageViewController class];
        }
        
        if(isa == nil) {
            NSLog(@"Not Implement Action %@",action);
            return;
        }
        
        viewController = [[isa alloc] initWithNibName:[action valueForKey:@"nibName"] bundle:self.bundle];
    }
    
    viewController.title = [action valueForKey:@"title"];
    
    if([viewController conformsToProtocol:@protocol(KKViewController)]) {
        id<KKViewController>  kkViewController = (id<KKViewController>) viewController;
        kkViewController.application = self;
        kkViewController.action = action;
    }
    
    if([(id) _delegate respondsToSelector:@selector(KKApplication:openViewController:)]) {
        if([_delegate KKApplication:self openViewController:viewController]) {
            return;
        }
    }
    
    UIViewController * topViewController = [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    if([topViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *) topViewController pushViewController:viewController animated:YES];
    } else {
        [topViewController presentViewController:viewController animated:YES completion:nil];
    }
}

-(UIViewController *) topViewController:(UIViewController *) viewController {
    
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

@end
