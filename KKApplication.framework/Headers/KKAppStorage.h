//
//  KKAppStorage.h
//  KKApplication
//
//  Created by 张海龙 on 2018/5/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKAppStorage;

typedef void (^KKAppStorageItemOnAppInfo)(NSDictionary * appInfo);

@interface KKAppStorageItem : NSObject

@property(nonatomic,weak,readonly) KKAppStorage * storage;
@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) NSArray<NSString *> * versions;
@property(nonatomic,strong,readonly) NSDate * modificationDate;

/**
 * 当前应用信息
 */
-(NSDictionary *) appInfo;

/**
 * 对应版本应用信息
 */
-(NSDictionary *) appInfo:(NSString *) version;

/**
 * 当前应用信息
 */
-(NSDictionary *) appInfoWithOnAppInfo:(KKAppStorageItemOnAppInfo) onAppInfo;

/**
 * 对应版本应用信息
 */
-(NSDictionary *) appInfo:(NSString *) version withOnAppInfo:(KKAppStorageItemOnAppInfo) onAppInfo;

@end

@interface KKAppStorage : NSObject

@property(nonatomic,strong,readonly) NSArray<KKAppStorageItem *> * items;
@property(nonatomic,strong,readonly) NSString * basePath;

-(instancetype) initWithBasePath:(NSString *) basePath;

/**
 * 加载目录应用
 */
-(void) load;

-(KKAppStorageItem *) itemWithKey:(NSString *) key;

-(KKAppStorageItem *) itemWithURL:(NSString *) url;

-(void) uninstallAppWithKey:(NSString *) key;
-(void) uninstallAppWithKey:(NSString *) key version:(NSString *) version;

-(void) uninstallAppWithURL:(NSString *) url;
-(void) uninstallAppWithURL:(NSString *) url version:(NSString *) version;

+(NSComparisonResult) compareVersion:(NSString *) version withVersion:(NSString *) withVersion;

@end
