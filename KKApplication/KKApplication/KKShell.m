//
//  KKShell.m
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import "KKShell.h"

typedef void (^KKShellOnLoadFunc)(NSURL * url,NSString * path);
typedef void (^KKShellOnErrorFunc)(NSURL * url,NSError * error);

@implementation KKShell

@synthesize delegate = _delegate;

-(void) dealloc {
    [[KKHttp main] cancel:self];
}

+(NSDictionary *) JOSNObject:(NSString *) path {
    NSData * data = [NSData dataWithContentsOfFile:path];
    if(data) {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return nil;
}

-(void) openApplication:(KKApplication *) app {

    if([(id)_delegate respondsToSelector:@selector(KKShell:openApplication:)]) {
        if([_delegate KKShell:self openApplication:app]) {
            return ;
        }
    }
    
    app.delegate = self;
    
    [app run];
}

-(void) open:(NSURL *) url path:(NSString *) path {
    
    NSDictionary * appInfo = [KKShell JOSNObject:[path stringByAppendingPathComponent:@"app.json"]];
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:open:path:appInfo:openApplication:)]) {
        
        __weak KKShell * v = self;
        
        if([_delegate KKShell:self open:url path:path appInfo:appInfo openApplication:^(KKApplication *app) {
            if(v){
                [v openApplication:app];
            }
        }]) {
            return;
        }
    }
    
    KKApplication * app = [[KKApplication alloc] initWithBundle:[NSBundle bundleWithPath:path]];
    
    [app.observer set:@[@"url"] value:[url absoluteString]];
    [app.observer set:@[@"path"] value:path];
    
    [self openApplication:app];
    
}

-(void) itemLoad:(NSInteger) index
           items:(NSArray *) items
         appInfo:(NSDictionary *) appInfo
             url:(NSURL *) url
            path:(NSString *) path
          onload:(KKShellOnLoadFunc) onload
         onerror:(KKShellOnErrorFunc) onerror {
 
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * version = [appInfo kk_getString:@"version"];
    
    __weak KKShell * shell = self;
    
    if(index < [items count]) {
        
        NSString * item = [items objectAtIndex:index];

        KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:[[NSURL URLWithString:item relativeToURL:url] absoluteString]];
        
        if([(id) shell.delegate respondsToSelector:@selector(KKShell:options:)]) {
            [shell.delegate KKShell:shell options:options];
        }
        
        options.type = KKHttpOptionsTypeURI;
        options.method = KKHttpOptionsGET;
        options.onfail = ^(NSError *error, id weakObject){
            [fm removeItemAtPath:[path stringByAppendingPathComponent:version] error:nil];
            if(onerror) {
                onerror(url,error);
            }
        };
        
        options.onload = ^(id data, NSError *error, id weakObject){
            if(error) {
                if(onerror) {
                    onerror(url,error);
                }
            } else {
                NSString * topath = [[path stringByAppendingPathComponent:version] stringByAppendingPathComponent:item] ;
                [fm createDirectoryAtPath:[topath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                [fm moveItemAtPath:(NSString *) data toPath:topath error:nil];
                [shell itemLoad:index + 1 items:items appInfo:appInfo url:url path:path onload:onload onerror:onerror];
            }
        };
        
        [[KKHttp main] send:options weakObject:self];
        
    } else {
        @autoreleasepool{
            NSData * data = [NSJSONSerialization dataWithJSONObject:appInfo options:NSJSONWritingPrettyPrinted error:nil];
            [data writeToFile:[[path stringByAppendingPathComponent:version] stringByAppendingPathComponent:@"app.json"] atomically:YES];
            [data writeToFile:[path stringByAppendingPathComponent:@"app.json"] atomically:YES];
        }
        if(onload) {
            onload(url,[path stringByAppendingPathComponent:version]);
        }
    }
    
}

-(void) load:(NSURL *) url onload:(KKShellOnLoadFunc) onload onerror:(KKShellOnErrorFunc) onerror{
    
    NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
    NSString * path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/kk"] stringByAppendingPathComponent:key];
    
    KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:[url absoluteString]];
    
    if([(id)_delegate respondsToSelector:@selector(KKShell:options:)]) {
        [_delegate KKShell:self options:options];
    }
    
    NSBundle * main = [NSBundle mainBundle];
    
    options.data = @{
                     @"appid":[[main infoDictionary] valueForKey:@"CFBundleIdentifier"],
                     @"version":[[main infoDictionary] valueForKey:@"CFBundleShortVersionString"],
                     @"kernel":[NSString stringWithFormat:@"%g", KKApplicationKernel]
                     };
    options.type = KKHttpOptionsTypeJSON;
    options.method = KKHttpOptionsGET;
    
    options.onfail = ^(NSError *error, id weakObject) {
        if(onerror) {
            onerror(url,error);
        }
    };
    
    options.onload = ^(id data, NSError *error, id weakObject) {
        if(error) {
            if(onerror) {
                onerror(url,error);
            }
        } else if(data == nil) {
            if(onerror) {
                onerror(url,[NSError errorWithDomain:@"KKShell" code:0 userInfo:[NSDictionary dictionaryWithObject:@"小应用加载错误" forKey:NSLocalizedDescriptionKey]]);
            }
        } else {
            
            NSLog(@"[KK] %@",data);
            
            NSString * version = [data kk_getString:@"version"];
            
            NSDictionary * appInfo = [KKShell JOSNObject:[path stringByAppendingPathComponent:@"app.json"]];
            
            if(appInfo == nil
               || ![[appInfo kk_getString:@"version"] isEqualToString:version]) {
                
                NSFileManager * fm = [NSFileManager defaultManager];

                [fm createDirectoryAtPath:[path stringByAppendingPathComponent:version] withIntermediateDirectories:YES attributes:nil error:nil];

                NSArray * items = [data kk_getValue:@"items"];
                
                if(![items isKindOfClass:[NSArray class]]) {
                    items = nil;
                }
                
                [self itemLoad:0 items:items appInfo:data url:url path:path onload:onload onerror:onerror];
                
            } else {
                if(onload) {
                    onload(url,path);
                }
            }
        }
    };
    
    [[KKHttp main] send:options weakObject:self];
}

-(void) open:(NSURL *) url {
    if([url isFileURL]) {
        [self open:url path:[url path]];
    } else {
        NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
        NSString * path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/kk"] stringByAppendingPathComponent:key];
        
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
                    [self open:url path:path];
                    [self load:url onload:nil onerror:^(NSURL *url, NSError *error) {
                        NSLog(@"[KK] %@",[url absoluteString]);
                        NSLog(@"[KK] %@",error);
                    }];
                    return;
                }
            }
        }
        
        if([(id) _delegate respondsToSelector:@selector(KKShell:willLoading:)]) {
            [_delegate KKShell:self willLoading:url];
        }
        
        {
            __weak KKShell * v = self;
            [self load:url onload:^(NSURL *url, NSString *path) {
                [v open:url path:path];
                if([(id) v.delegate respondsToSelector:@selector(KKShell:didLoading:path:)]) {
                    [v.delegate KKShell:v didLoading:url path:path];
                }
            } onerror:^(NSURL *url, NSError *error) {
                if([(id)v.delegate respondsToSelector:@selector(KKShell:didFailWithError:url:)]) {
                    [v.delegate KKShell:v didFailWithError:error url:url];
                }
            }];
        }
        
    }
}

-(void) update:(NSURL *) url {
    if([url isFileURL]) {
        
    } else {
        [self load:url onload:nil onerror:^(NSURL *url, NSError *error) {
            NSLog(@"[KK] %@",[url absoluteString]);
            NSLog(@"[KK] [Fail] %@",error);
        }];
    }
}

-(BOOL) has:(NSURL *) url {
    if([url isFileURL]) {
        NSFileManager * fm = [NSFileManager defaultManager];
        return [fm fileExistsAtPath:[url path]];
    } else {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * key = [KKHttpOptions cacheKeyWithURL:[url absoluteString]];
        NSString * path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/kk"] stringByAppendingPathComponent:key];
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
            [self open:[NSURL URLWithString:v]];
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

-(BOOL) KKApplication:(KKApplication *) application openViewController:(UIViewController *) viewController {
    if([(id)_delegate respondsToSelector:@selector(KKShell:application:openViewController:)]) {
        if( [_delegate KKShell:self application:application openViewController:viewController] ) {
            return YES;
        }
    }
    
    return NO;
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
