//
//  KKAppLoading.m
//  KKApplication
//
//  Created by hailong11 on 2018/6/5.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKAppLoading.h"
#import <KKHttp/KKHttp.h>
#import <KKObserver/KKObserver.h>
#import <CommonCrypto/CommonCrypto.h>

#define kSkipLocalFiles @"_skipLocalFiles"

@implementation KKAppLoading

-(instancetype) initWithURL:(NSString *) url path:(NSString *) path http:(KKAppLoadingSendFunc) http {
    if((self = [super init])) {
        _url = url;
        _path = path;
        _key = [KKHttpOptions cacheKeyWithURL:url];
        _http = http;
    }
    return self;
}

-(void) onError:(NSError *)error {
    
    NSLog(@"[KK] [APP] [ERROR] %@",[error localizedDescription]);
    
    if(_onerror != nil) {
        _onerror(_URL,error);
    }
}

-(void) onLoad:(NSString *) path {
    
    NSLog(@"[KK] [APP] [OK] %@ %@",_url,_path);
    
    if(_onload != nil) {
        _onload(_URL,path,self);
    }
}

-(void) onProgress:(NSInteger) count totalCount:(NSInteger) totalCount {
    if(_onprogress != nil) {
        _onprogress(_URL,_path,count,totalCount);
    }
}

+(NSMutableDictionary *) JOSNObject:(NSString *) path {
    NSData * data = [NSData dataWithContentsOfFile:path];
    if(data) {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return nil;
}

-(void) onAppInfo:(id) data{
    
    if(_onappinfo) {
        _onappinfo(_URL,_path,self,data);
    }
    
    NSString * version = [data kk_getString:@"version"];
    NSString * ver = [data kk_getString:@"ver"];
    
    NSString * basePath = [_path stringByAppendingPathComponent:version];
    
    NSDictionary * appInfo = [KKAppLoading JOSNObject:[basePath stringByAppendingPathComponent:@"app.json"]];

    NSMutableDictionary * vers = nil;
    
    NSArray * items = [data kk_getValue:@"res"];
    
    if(![items isKindOfClass:[NSArray class]]) {
        items = nil;
    }
    
    if(items == nil) {
        items = [data kk_getValue:@"items"];
        if(![items isKindOfClass:[NSArray class]]) {
            items = nil;
        }
    }
    
    BOOL skipLocalFiles = [[appInfo kk_getValue:kSkipLocalFiles] boolValue];
    
    if([appInfo kk_getString:@"md5"] != nil
       && [version isEqualToString:[appInfo kk_getString:@"version"]]
       && ! skipLocalFiles) {
    
        NSString * ver1 = [appInfo kk_getString:@"ver"];
        NSString * ver2 = [data kk_getString:@"ver"];
        
        if(ver1 != nil && ver2 != nil && [ver1 isEqualToString:ver2]) {
            
            [self onLoad:[_path stringByAppendingPathComponent:version]];
            
            return;
        }

        NSArray* its = [appInfo kk_getValue:@"res"];
        
        if(![its isKindOfClass:[NSArray class]]) {
            its = nil;
        }
        
        if(its == nil) {
            its = [appInfo kk_getValue:@"items"];
            if(![its isKindOfClass:[NSArray class]]) {
                its = nil;
            }
        }
        
        if([its isKindOfClass:[NSArray class]]) {
            
            vers = [NSMutableDictionary dictionaryWithCapacity:4];
            
            for(id item in its) {
                if([item isKindOfClass:[NSDictionary class]]) {
                    NSString * ver = [item kk_getString:@"ver"];
                    NSString * path = [item kk_getString:@"path"];
                    if(ver && path ) {
                        vers[path] = ver;
                    }
                }
            }
            
        }
    }
    
    NSString * tPath = [_path stringByAppendingString:[NSString stringWithFormat:@"_%@_%@",version,ver]];
    
    [self itemLoad:0
             items:items
           appInfo:data
              vers:vers
          basePath:basePath
             tPath:tPath
    skipLocalFiles:skipLocalFiles];
    
}

-(void) itemLoad:(NSInteger) index
           items:(NSArray *) items
         appInfo:(NSDictionary *) appInfo
            vers:(NSDictionary *) vers
        basePath:(NSString *) basePath
           tPath:(NSString *) tPath
  skipLocalFiles:(BOOL) skipLocalFiles {
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    __weak KKAppLoading * loading = self;
    
    [self onProgress:index totalCount:[items count]];
    
    if(index < [items count]) {
        
        id item = [items objectAtIndex:index];
        NSString * topath = nil;
        NSString * tpath = nil;
        
        if([item isKindOfClass:[NSDictionary class]]) {
            
            NSString * ver = [item kk_getString:@"ver"];
            item = [item kk_getString:@"path"];
            
            if([item isEqualToString:@"app.json"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loading itemLoad:index + 1
                                items:items
                              appInfo:appInfo
                                 vers:vers
                             basePath:basePath
                                tPath:tPath
                       skipLocalFiles:skipLocalFiles];
                });
                return;
            }
            
            if([(NSString *) item containsString:@".."]) {
                [fm removeItemAtPath:tPath error:nil];
                [loading onError:[NSError errorWithDomain:@"KKAppLoading"
                                                  code:-500
                                              userInfo:[NSDictionary dictionaryWithObject:@"错误的资源路径" forKey:NSLocalizedDescriptionKey]]];
                return;
            }
            
            topath = [basePath stringByAppendingPathComponent:item];
            tpath = [tPath stringByAppendingPathComponent:item];
            
            NSString * localVer = [vers valueForKey:item];
            
            if(!skipLocalFiles && (localVer == nil || [localVer isEqualToString:ver])) {
                if([fm fileExistsAtPath:topath]) {
                    [fm createDirectoryAtPath:[tpath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                    [fm copyItemAtPath:topath toPath:tpath error:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [loading itemLoad:index + 1
                                    items:items
                                  appInfo:appInfo
                                     vers:vers
                                 basePath:basePath
                                    tPath:tPath
                           skipLocalFiles:skipLocalFiles];
                    });
                    return;
                }
            }
            
            if(ver) {
                item = [NSString stringWithFormat:@"%@?v=%@",item,ver];
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading itemLoad:index + 1
                            items:items
                          appInfo:appInfo
                             vers:vers
                         basePath:basePath
                            tPath:tPath
                   skipLocalFiles:skipLocalFiles];
            });
            return;
        }
        
        KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:[[NSURL URLWithString:[item stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:_URL] absoluteString]];
        
        options.type = KKHttpOptionsTypeURI;
        options.method = KKHttpOptionsGET;
        options.onfail = ^(NSError *error, id weakObject){
            [fm removeItemAtPath:tPath error:nil];
            [loading onError:error];
        };
        
        options.onload = ^(id data, NSError *error, id weakObject){
            if(error) {
                [fm removeItemAtPath:tPath error:nil];
                [loading onError:error];
            } else {
                [fm createDirectoryAtPath:[tpath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                [fm removeItemAtPath:tpath error:nil];
                [fm moveItemAtPath:(NSString *) data toPath:tpath error:nil];
                [loading itemLoad:index + 1
                          items:items
                        appInfo:appInfo
                           vers:vers
                         basePath:basePath
                            tPath:tPath
                   skipLocalFiles:skipLocalFiles];
            }
        };
        
        NSLog(@"[KK] [APP] %@",options.absoluteUrl);
        
        _http(options);
        
    } else {
        [self verify:items appInfo:appInfo basePath:basePath tPath:tPath];
    }
}

//校验应用包
-(void) verify:(NSArray *) items
       appInfo:(NSDictionary *) appInfo
      basePath:(NSString *) basePath
         tPath:(NSString *) tPath {

    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSString * md5 = [appInfo kk_getString:@"md5"];
    
    __weak KKAppLoading * loading = self;
    
    NSString * path = _path;
    
    dispatch_async(KKHttpIODispatchQueue(), ^{
        
        NSString *v = nil;
        
        if(md5 != nil ) {
            
            CC_MD5_CTX ctx;
            
            CC_MD5_Init(&ctx);
            
            for(id item in items) {
                
                @autoreleasepool {
                    
                    NSString * itemPath = [item kk_getString:@"path"];
                    
                    if(itemPath == nil || [itemPath isEqualToString:@"app.json"]) {
                        continue;
                    }
                    
                    CC_MD5_Update(&ctx, [itemPath UTF8String], (CC_LONG) [itemPath length]);
                    
                    NSData * data = [NSData dataWithContentsOfFile:[tPath stringByAppendingPathComponent:itemPath]];
                    
                    if([data length] == 0) {
                        NSLog(@"[KK] [HTTP] [DATA] [NIL] %@",[tPath stringByAppendingPathComponent:itemPath]);
                    }
                    
                    CC_MD5_Update(&ctx, [data bytes], (CC_LONG) [data length]);
                }
                
            }
            
            unsigned char md[16];
            
            CC_MD5_Final(md, &ctx);
            
            v = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
                            ,md[0],md[1],md[2],md[3],md[4],md[5],md[6],md[7]
                            ,md[8],md[9],md[10],md[11],md[12],md[13],md[14],md[15]];
            
        }
        
        if(md5 == nil || [v isEqualToString:md5]) {
            
            NSData * data = [NSJSONSerialization dataWithJSONObject:appInfo options:NSJSONWritingPrettyPrinted error:nil];
            
            [fm createDirectoryAtPath:[basePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            [fm removeItemAtPath:basePath error:nil];
            [fm moveItemAtPath:tPath toPath:basePath error:nil];
            
            [data writeToFile:[basePath stringByAppendingPathComponent:@"app.json"] atomically:YES];
            [data writeToFile:[path stringByAppendingPathComponent:@"app.json"] atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading onLoad:basePath];
            });
            
        } else {
            
            NSMutableDictionary * appInfo = [[KKAppLoading JOSNObject:[basePath stringByAppendingPathComponent:@"app.json"]] mutableCopy];
            
            if(appInfo != nil && [appInfo isKindOfClass:[NSMutableDictionary class]]) {
                [appInfo setValue:@(true) forKey:kSkipLocalFiles];
                NSData * data = [NSJSONSerialization dataWithJSONObject:appInfo options:NSJSONWritingPrettyPrinted error:nil];
                [data writeToFile:[basePath stringByAppendingPathComponent:@"app.json"] atomically:YES];
            }
            
            [fm removeItemAtPath:tPath error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [loading onError:[NSError errorWithDomain:@"KKShell" code:-300 userInfo:@{NSLocalizedDescriptionKey:@"错误的应用包,应用包校验失败"}]];
            });
            
        }
        
    });
    
}

-(void) start {
    
    @try {
        _URL = [NSURL URLWithString:_url];
    }
    @catch(NSException *ex) {
        [self onError:[NSError errorWithDomain:@"KKAppLoading" code:-200 userInfo:@{NSLocalizedDescriptionKey:@"错误的URL"}]];
    }
    
    __weak KKAppLoading * loading = self;
    
    KKHttpOptions * options = [[KKHttpOptions alloc] initWithURL:[_URL absoluteString]];
    
    options.type = KKHttpOptionsTypeJSON;
    options.method = KKHttpOptionsGET;
    options.timeout = 10;
    
    options.onfail = ^(NSError *error, id weakObject) {
        [loading onError:error];
    };
    
    options.onload = ^(id data, NSError *error, id weakObject) {
        if(error) {
            [loading onError:error];
        } else if(data == nil) {
            [loading onError:[NSError errorWithDomain:@"KKAppLoading" code:0 userInfo:[NSDictionary dictionaryWithObject:@"小应用加载错误" forKey:NSLocalizedDescriptionKey]]];
        } else {
            [loading onAppInfo:data];
        }
    };
    
    NSLog(@"[KK] [APP] [LOADING] %@",options.absoluteUrl);
    
    _http(options);
    
}

@end
