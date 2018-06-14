//
//  KKAppStorage.m
//  KKApplication
//
//  Created by 张海龙 on 2018/5/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKAppStorage.h"
#import <KKHttp/KKHttp.h>

@interface KKAppStorageItem() {
    NSDictionary * _appInfo;
    NSMutableDictionary * _appInfoWithVersion;
    NSMutableArray * _versions;
}

-(instancetype) initWithStorage:(KKAppStorage *) storage
                            key:(NSString *) key
               modificationDate:(NSDate *) modificationDate
                       versions:(NSArray<NSString *> *) versions;

-(void) removeVersion:(NSString *) version;

@end

@implementation KKAppStorageItem

@synthesize versions = _versions;

-(instancetype) initWithStorage:(KKAppStorage *) storage
                            key:(NSString *) key
               modificationDate:(NSDate *) modificationDate
                       versions:(NSArray<NSString *> *) versions{
    if((self = [super init])) {
        _storage = storage;
        _key = key;
        _modificationDate = modificationDate;
        _versions= [NSMutableArray arrayWithArray:versions];
    }
    return self;
}

/**
 * 当前应用信息
 */
-(NSDictionary *) appInfo {
    if( _appInfo == nil ){
        NSString * path = [[self.storage.basePath stringByAppendingPathComponent:self.key] stringByAppendingPathComponent:@"app.json"];
        NSData * data = [NSData dataWithContentsOfFile:path];
        if(data) {
            NSDictionary * v = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self setAppInfo:v];
        }
    }
    return _appInfo;
}

/**
 * 对应版本应用信息
 */
-(NSDictionary *) appInfo:(NSString *) version {
    NSDictionary * v = [_appInfoWithVersion valueForKey:version];
    if(v == nil) {
        NSString * path = [[[self.storage.basePath stringByAppendingPathComponent:self.key]
                            stringByAppendingPathComponent:version] stringByAppendingPathComponent:@"app.json"];
        
        NSData * data = [NSData dataWithContentsOfFile:path];
        
        if(data!= nil) {
            v = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self setAppInfo:v withVersion:version];
        }
    }
    return v;
}

-(void) setAppInfo:(NSDictionary *) appInfo {
    _appInfo = appInfo;
}

-(void) setAppInfo:(NSDictionary *) appInfo withVersion:(NSString *) withVersion {
    if(appInfo != nil) {
        if(_appInfoWithVersion == nil) {
            _appInfoWithVersion = [[NSMutableDictionary alloc] initWithCapacity:4];
        }
        _appInfoWithVersion[withVersion] = appInfo;
    }
}

/**
 * 当前应用信息
 */
-(NSDictionary *) appInfoWithOnAppInfo:(KKAppStorageItemOnAppInfo) onAppInfo {
    if(_appInfo == nil && onAppInfo != nil) {
        
        NSString * path = [[self.storage.basePath stringByAppendingPathComponent:self.key] stringByAppendingPathComponent:@"app.json"];
        
        __weak KKAppStorageItem * item = self;
        
        dispatch_async(KKHttpIODispatchQueue(), ^{
            if(item) {
                NSMutableDictionary * v = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [item setAppInfo:v];
                });
            }
        });
    }
    return _appInfo;
}

/**
 * 对应版本应用信息
 */
-(NSDictionary *) appInfo:(NSString *) version withOnAppInfo:(KKAppStorageItemOnAppInfo) onAppInfo {
    NSDictionary * v = [_appInfoWithVersion valueForKey:version];
    if(v == nil && onAppInfo != nil) {
        
        NSString * path = [[[self.storage.basePath stringByAppendingPathComponent:self.key] stringByAppendingPathComponent:version] stringByAppendingPathComponent:@"app.json"];
        
        __weak KKAppStorageItem * item = self;
        
        dispatch_async(KKHttpIODispatchQueue(), ^{
            if(item) {
                NSMutableDictionary * v = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [item setAppInfo:v withVersion:version];
                });
            }
        });
    }
    return v;
}

-(void) removeVersion:(NSString *) version {
    _appInfo = nil;
    [_appInfoWithVersion removeObjectForKey:version];
    [_versions removeObject:version];
}

@end

@interface KKAppStorage(){
    NSMutableDictionary * _appItemWithKey;
    NSMutableArray * _appItems;
}

@end

@implementation KKAppStorage

-(instancetype) initWithBasePath:(NSString *) basePath {
    if((self = [super init])) {
        _basePath = basePath;
    }
    return self;
}

+(NSComparisonResult) compareVersion:(NSString *) version withVersion:(NSString *) withVersion {
    
    NSArray * vs1 = [version componentsSeparatedByString:@"."];
    NSArray * vs2 = [withVersion componentsSeparatedByString:@"."];
    
    for(NSInteger i=0;i<[vs1 count] && i < [vs2 count];i++) {
        NSString * v1 = vs1[i];
        NSString * v2 = vs2[i];
        NSComparisonResult r = [v1 compare:v2];
        if(r != NSOrderedSame) {
            return r;
        }
    }
    
    if([vs1 count] == [vs2 count]) {
        return NSOrderedSame;
    }
    
    if([vs1 count] < [vs2 count]) {
        return NSOrderedAscending;
    }
    
    return NSOrderedDescending;
}

-(NSArray *) versionsWithPath:(NSString *) path {
    NSMutableArray * vs = [NSMutableArray arrayWithCapacity:4];
    NSFileManager * fm = [NSFileManager defaultManager];
    
    for(NSString * key in [fm contentsOfDirectoryAtPath:path error:nil]) {
        NSDictionary * attr = [fm attributesOfItemAtPath:[path stringByAppendingPathComponent:key] error:nil];
        if(attr != nil && [[attr fileType] isEqualToString:NSFileTypeDirectory]) {
            [vs addObject:key];
        }
    }
    
    [vs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult r = [KKAppStorage compareVersion:obj1 withVersion:obj2];
        if(r == NSOrderedDescending) {
            return NSOrderedAscending;
        } else if(r == NSOrderedAscending) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    return vs;
}
/**
 * 加载目录应用
 */
-(void) load {
    
    NSMutableArray * items = [NSMutableArray arrayWithCapacity:4];
    NSMutableDictionary * itemWithKey = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    

    for(NSString * key in [fm contentsOfDirectoryAtPath:_basePath error:nil]) {
        NSDictionary * attr = [fm attributesOfItemAtPath:[_basePath stringByAppendingPathComponent:key] error:nil];
        if(attr != nil && [[attr fileType] isEqualToString:NSFileTypeDirectory]) {
            NSArray<NSString *> * versions = [self versionsWithPath:[_basePath stringByAppendingPathComponent:key]];
            KKAppStorageItem * item = [[KKAppStorageItem alloc] initWithStorage:self key:key modificationDate:[attr fileModificationDate] versions:versions];
            [items addObject:item];
            itemWithKey[key] = item;
        }
    }
    
    [items sortUsingComparator:^NSComparisonResult(id  obj1, id  obj2) {
        NSComparisonResult r = [[(KKAppStorageItem *) obj1 modificationDate]
                                compare:[(KKAppStorageItem *) obj2 modificationDate] ];
        if(r == NSOrderedAscending) {
            return NSOrderedDescending;
        } else if(r == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    _appItems = items;
    _appItemWithKey = itemWithKey;
    
}

-(NSArray<KKAppStorageItem *> *) items {
    return _appItems;
}

-(KKAppStorageItem *) itemWithKey:(NSString *) key {
    return [_appItemWithKey valueForKey:key];
}

-(KKAppStorageItem *) itemWithURL:(NSString *) url {
    return [self itemWithKey:[KKHttpOptions cacheKeyWithURL:url]];
}

-(void) uninstallAppWithKey:(NSString *) key {
    [self uninstallAppWithKey:key version:nil];
}

-(void) uninstallAppWithKey:(NSString *) key version:(NSString *) version {
    
    KKAppStorageItem * item = [self itemWithKey:key];
    
    if(item != nil) {
        NSInteger i=0;
        for(;i<[item.versions count];i++){
            NSString * v = [item.versions objectAtIndex:i];
            if([v isEqualToString:version]) {
                break;
            }
        }
        if(i<[item.versions count]) {
            if([item.versions count] ==1) {
                NSString * path = [self.basePath stringByAppendingPathComponent:key];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [_appItemWithKey removeObjectForKey:key];
                [_appItems removeObject:item];
            } else if(i == 0) {
                NSString * path = [[self.basePath stringByAppendingPathComponent:key] stringByAppendingPathComponent:@"app.json"];
                NSString * v = [item.versions objectAtIndex:1];
                NSDictionary *appInfo = [item appInfo:v];
                if(appInfo) {
                    [[NSJSONSerialization dataWithJSONObject:appInfo options:NSJSONWritingPrettyPrinted error:nil] writeToFile:path atomically:YES];
                }
                path = [[self.basePath stringByAppendingPathComponent:key] stringByAppendingPathComponent:item.versions[0]];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [item removeVersion:item.versions[0]];
            } else {
                NSString * path = [[self.basePath stringByAppendingPathComponent:key] stringByAppendingPathComponent:item.versions[i]];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [item removeVersion:item.versions[i]];
            }
        }
    }
}

-(void) uninstallAppWithURL:(NSString *) url {
    [self uninstallAppWithURL:url version:nil];
}

-(void) uninstallAppWithURL:(NSString *) url version:(NSString *) version {
    [self uninstallAppWithKey:[KKHttpOptions cacheKeyWithURL:url] version:version];
}

@end
