//
//  KKAppLoading.h
//  KKApplication
//
//  Created by hailong11 on 2018/6/5.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKHttp/KKHttp.h>

@class KKAppLoading;

typedef void (^KKAppLoadingOnLoadFunc)(NSURL * url,NSString * path,KKAppLoading * loading);
typedef void (^KKAppLoadingOnAppInfoFunc)(NSURL * url,NSString * path,KKAppLoading * loading,id appInfo);
typedef void (^KKAppLoadingOnProgressFunc)(NSURL * url,NSString * path,NSInteger count,NSInteger totalCount);
typedef void (^KKAppLoadingOnErrorFunc)(NSURL * url,NSError * error);
typedef void (^KKAppLoadingSendFunc)(KKHttpOptions * options);

@interface KKAppLoading : NSObject

@property(nonatomic,strong,readonly) KKAppLoadingSendFunc http;
@property(nonatomic,strong,readonly) NSURL * URL;
@property(nonatomic,strong,readonly) NSString * url;
@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) NSString * path;

@property(nonatomic,assign,getter=isCanceled) BOOL canceled;
@property(nonatomic,strong) KKAppLoadingOnLoadFunc onload;
@property(nonatomic,strong) KKAppLoadingOnProgressFunc onprogress;
@property(nonatomic,strong) KKAppLoadingOnErrorFunc onerror;
@property(nonatomic,strong) KKAppLoadingOnAppInfoFunc onappinfo;

-(instancetype) initWithURL:(NSString *) url path:(NSString *) path http:(KKAppLoadingSendFunc) http;

-(void) start;

@end
