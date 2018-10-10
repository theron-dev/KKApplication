//
//  KKShell.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKShell.h"
#import "KKGeoLocation.h"

@interface KKShell() {
    NSMutableDictionary * _loadings;
}

-(KKAppLoading *) setLoading:(NSString *) key loading:(KKAppLoading *) loading ;

-(KKAppLoading *) cancelLoading:(NSString *) key;

@end

@implementation KKShell

+(void) initialize {
    [KKGeoLocation openlibs];
}

@synthesize delegate = _delegate;

-(instancetype) init {
    if((self = [super initWithBasePath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/kk"]])) {
        
    }
    return self;
}

-(void) dealloc {
    
    if([(id) _delegate respondsToSelector:@selector(KKShell:application:cancel:)]
       && [_delegate KKShell:self application:nil cancel:self]) {
    } else {
        [[KKHttp main] cancel:self];
    }
    
}

+(NSDictionary *) JOSNObject:(NSString *) path {
    NSData * data = [NSData dataWithContentsOfFile:path];
    if(data) {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return nil;
}

-(KKProtocol *) protocol {
    if(_protocol == nil) {
        _protocol = [KKProtocol main];
    }
    return _protocol;
}

-(void) openApplication:(KKApplication *) app {
    [self openApplication:app query:nil];
}

-(void) openApplication:(KKApplication *) app query:(NSDictionary *) query {

    if([(id)_delegate respondsToSelector:@selector(KKShell:openApplication:)]) {
        if([_delegate KKShell:self openApplication:app]) {
            return ;
        }
    }
    
    __weak KKShell * shell = self;
    
    if(_mainApplication == nil) {
        
        _mainApplication = app;

        [app.observer on:^(id value, NSArray *changedKeys, void *context) {
            
            if(shell && [value isKindOfClass:[NSDictionary class]]) {
                NSString * url = [value kk_getString:@"url"];
                if(url != nil) {
                    NSURL * u = nil;
                    @try {
                        u = [NSURL URLWithString:url];
                    }
                    @catch(NSException *ex) {
                        
                    }
                    
                    if(u) {
                        [[shell isLoading:u] cancel];
                    }
                }
            }
            
        } keys:@[@"app",@"cancel"] context:nil];
        
    }
    
    [app.observer on:^(id value, NSArray *changedKeys, void *context) {
        
        if(shell && [value isKindOfClass:[NSDictionary class]]) {
            NSString * url = [value kk_getString:@"url"];
            if(url != nil) {
                NSURL * u = nil;
                
                @try {
                    u = [NSURL URLWithString:url];
                }
                @catch(NSException *ex) {}
                
                BOOL checkUpdate =  KKBooleanValue([value kk_getValue:@"checkUpdate"]);
                
                if(u) {
                    if(checkUpdate || ![shell has:u]) {
                        [shell update:u];
                    }
                }
            }
        }
        
    } keys:@[@"app",@"update"] context:nil];
    
    app.delegate = self;
    [app.observer set:@[@"query"] value:query];
    
    [self.protocol openApplication:app];
    
    [app run];
}

-(void) open:(NSURL *) url query:(NSDictionary *) query path:(NSString *) path {
    
    NSDictionary * appInfo = [KKShell JOSNObject:[path stringByAppendingPathComponent:@"app.json"]];
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:open:path:appInfo:openApplication:)]) {
        
        __weak KKShell * v = self;
        
        if([_delegate KKShell:self open:url path:path appInfo:appInfo openApplication:^(KKApplication *app) {
            if(v){
                [v openApplication:app query:query];
            }
        }]) {
            return;
        }
    }
    
    KKApplication * app = [[KKApplication alloc] initWithBundle:[NSBundle bundleWithPath:path]];
    
    [app.observer set:@[@"url"] value:[url absoluteString]];
    [app.observer set:@[@"path"] value:path];
    if(![url isFileURL]) {
        [app.observer set:@[@"key"] value:[KKHttpOptions cacheKeyWithURL:[url absoluteString]]];
    }
    [app.observer set:@[@"query"] value:query];
    
    if(appInfo != nil ){
        [app.observer set:@[@"info"] value:appInfo];
    }
    
    [self openApplication:app query:query];
    
}

-(KKAppLoading *) load:(NSURL *) url onload:(KKAppLoadingOnLoadFunc) onload {

    KKAppLoading * loading = [self isLoading:url];
    
    BOOL isRestart = NO;
    
    __weak KKShell * shell = self;
    NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
    NSString * path = [self.basePath stringByAppendingPathComponent:key];
    if(loading == nil) {
        loading = [[KKAppLoading alloc] initWithURL:[url absoluteString] path:path http:^(KKHttpOptions *options) {
            [[KKHttp main] send:options weakObject:shell];
        }];
        
        [self setLoading:key loading:loading];
        
    } else {
        isRestart = YES;
    }
    
    loading.onload = ^(NSURL *url, NSString *path, KKAppLoading *loading) {
        [shell cancelLoading:key];
        if(shell && onload != nil) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:didLoading:path:)]) {
                [shell.delegate KKShell:shell didLoading:url path:path];
            }
            onload(url,path,loading);
        }
    };
    
    loading.onerror = ^(NSURL *url, NSError *error) {
        [shell cancelLoading:key];
        if(shell && onload != nil) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:didFailWithError:url:)]) {
                [shell.delegate KKShell:shell didFailWithError:error url:url];
            }
        }
    };
    
    loading.onprogress = ^(NSURL *url, NSString *path, NSInteger count, NSInteger totalCount) {
        if(shell && onload != nil) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:loading:path:count:totalCount:)]) {
                [shell.delegate KKShell:shell loading:url path:path count:count totalCount:totalCount];
            }
        }
    };

    loading.onappinfo = ^(NSURL *url, NSString *path, KKAppLoading *loading, id appInfo) {
        if(shell && onload != nil) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:loading:path:appInfo:)]) {
                [shell.delegate KKShell:shell loading:url path:path appInfo:appInfo];
            }
        }
    };
    
    if(onload != nil) {
        
        if([(id)self.delegate respondsToSelector:@selector(KKShell:willLoading:)]) {
            [self.delegate KKShell:self willLoading:url];
        }
        
        if(loading.appInfo != nil) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:loading:path:appInfo:)]) {
                [shell.delegate KKShell:shell loading:url path:path appInfo:loading.appInfo];
            }
        }
        
        if(loading.totalCount > 0) {
            if([(id)shell.delegate respondsToSelector:@selector(KKShell:loading:path:count:totalCount:)]) {
                [shell.delegate KKShell:shell loading:url path:path count:loading.count totalCount:loading.totalCount];
            }
        }
        
    }
    
    if(isRestart) {
        [loading restart];
    } else {
        [loading start];
    }
    
    return loading;
}

-(void) open:(NSURL *) url{
    [self open:url query:nil checkUpdate:NO];
}

-(void) open:(NSURL *) url query:(NSDictionary *) query {
     [self open:url query:query checkUpdate:NO];
}

-(void) open:(NSURL *) url query:(NSDictionary *) query checkUpdate:(BOOL) checkUpdate {
    if([url isFileURL]) {
        [self open:url query:query path:[url path]];
    } else {
        NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
        NSString * path = [self.basePath stringByAppendingPathComponent:key];
        
        if(!checkUpdate) {
            NSFileManager * fm = [NSFileManager defaultManager];
            NSDictionary * appInfo = nil;
            
            if([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"app.json"]]) {
                NSData * data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"app.json"]];
                appInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
            
            if(appInfo) {
                
                NSString * version = [appInfo kk_getString:@"version"];
                
                if(version) {
                    
                    path = [path stringByAppendingPathComponent:version];
                    
                    if([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"app.json"]]) {
                        [self open:url query:query path:path];
                        [self load:url
                            onload:nil];
                        return;
                    }
                }
            }
        }
        
        if([(id) _delegate respondsToSelector:@selector(KKShell:willLoading:)]) {
            [_delegate KKShell:self willLoading:url];
        }
        
        {
            __weak KKShell * v = self;
            [self load:url
                onload:^(NSURL *url, NSString *path,KKAppLoading * loading) {
                    if(loading == nil || !loading.canceled) {
                        [v open:url query:query path:path];
                    }
                }];
        }
        
    }
}

-(void) update:(NSURL *) url {
    if([url isFileURL]) {
        
    } else {
        [self load:url
            onload:nil];
    }
}

-(BOOL) has:(NSURL *) url {
    if([url isFileURL]) {
        NSFileManager * fm = [NSFileManager defaultManager];
        return [fm fileExistsAtPath:[url path]];
    } else {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
        NSString * path = [self.basePath stringByAppendingPathComponent:key];
        return [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"app.json"]];
    }
}

-(BOOL) KKApplication:(KKApplication *) application openAction:(NSDictionary *) action {
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:openAction:)]) {
        if([_delegate KKShell:self application:application openAction:action]) {
            return YES;
        }
    }
    
    if([[action kk_getString:@"type"] isEqualToString:@"app"]) {
        
        NSString * v = [action kk_getString:@"url"];
        
        if(v) {
            
            NSArray * vs = [[action kk_getString:@"back"] componentsSeparatedByString:@"/"];
            
            if([vs count]) {
                
                UIViewController * topViewController = [KKApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                
                for(NSString * v in vs) {
                    
                    if([v isEqualToString:@".."]) {
                        if([topViewController isKindOfClass:[UINavigationController class]]) {
                            [(UINavigationController *) topViewController popViewControllerAnimated:NO];
                        }
                    }
                    
                }
            }
            
            [self open:[NSURL URLWithString:v] query:[action kk_getValue:@"query"] checkUpdate:[[action kk_getValue:@"checkUpdate"] boolValue]];
            
        }
        
        return YES;
    }
    
    return NO;
}

-(UIViewController *) KKApplication:(KKApplication *) application viewController:(NSDictionary *) action {
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:viewController:)]) {
        UIViewController * v = [_delegate KKShell:self application:application viewController:action];
        if(v) {
            return v;
        }
    }
    
    return nil;
}

-(id<KKHttpTask>) KKApplication:(KKApplication *) application send:(KKHttpOptions *) options weakObject:(id) weakObject  {
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:send:weakObject:)]) {
        return [_delegate KKShell:self application:application send:options weakObject:weakObject];
    }
    
    return nil;
}
    
-(BOOL) KKApplication:(KKApplication *) application cancel:(id) weakObject {
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:cancel:)]) {
        return [_delegate KKShell:self application:application cancel:weakObject];
    }
    
    return NO;
}

-(void) KKApplication:(KKApplication *)application willSend:(KKHttpOptions *)options {
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:willSend:)]) {
        [_delegate KKShell:self application:application willSend:options];
    }
    
}

-(BOOL) KKApplication:(KKApplication *) application openViewController:(UIViewController *) viewController action:(NSDictionary *)action {
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:openViewController:action:)]) {
        if( [_delegate KKShell:self application:application openViewController:viewController action:action] ) {
            return YES;
        }
    }
    
    return NO;
}

-(KKAppLoading *) isLoading:(NSURL *) url {
    if([url isFileURL]) {
        return nil;
    }
    return [_loadings valueForKey:[KKHttpOptions cacheKeyWithURL:[url absoluteString]]];
}

-(KKAppLoading *) setLoading:(NSString *) key loading:(KKAppLoading *) loading {
    if(_loadings == nil){
        _loadings = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    [_loadings setValue:loading forKey:key];
    return loading;
}

-(KKAppLoading *) cancelLoading:(NSString *) key {
    KKAppLoading * loading = [_loadings valueForKey:key];
    if(loading != nil) {
        [_loadings removeObjectForKey:key];
    }
    return loading;
}

+(KKShell *) main {
    static KKShell * v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[KKShell alloc] init];
    });
    return v;
}

@end
