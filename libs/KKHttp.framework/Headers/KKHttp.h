//
//  KKHttp.h
//  KKView
//
//  Created by 张海龙 on 2017/10/26.
//  Copyright © 2017年 ziyouker.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKHttp/KKJSHttp.h>
#import <JavaScriptCore/JavaScriptCore.h>

extern NSString * KKHttpOptionsTypeText;
extern NSString * KKHttpOptionsTypeJSON;
extern NSString * KKHttpOptionsTypeData;
extern NSString * KKHttpOptionsTypeURI;
extern NSString * KKHttpOptionsTypeImage;

extern NSString * KKHttpOptionsGET;
extern NSString * KKHttpOptionsPOST;

typedef void (^KKHttpOnLoad)(id data,NSError * error, id weakObject);
typedef void (^KKHttpOnFail)(NSError * error, id weakObject);
typedef void (^KKHttpOnResponse)(NSHTTPURLResponse * response, id weakObject);
typedef void (^KKHttpOnProcess)(long long value, long long maxValue,id weakObject);

@interface UIImage(KKHttp)

+(UIImage *) kk_imageWithPath:(NSString *) path;

@end

@interface KKHttpOptions : NSObject {
    
}
    
@property(nonatomic,strong) NSString * url;
@property(nonatomic,strong) NSString * method;
@property(nonatomic,strong) id data;
@property(nonatomic,strong) NSMutableDictionary * headers;
@property(nonatomic,strong) NSString * type;
@property(nonatomic,assign) NSTimeInterval timeout;
@property(nonatomic,strong) NSString * host;    //代理主机

@property(nonatomic,copy) KKHttpOnLoad onload;
@property(nonatomic,copy) KKHttpOnFail onfail;
@property(nonatomic,copy) KKHttpOnResponse onresponse;
@property(nonatomic,copy) KKHttpOnProcess onprocess;

@property(nonatomic,strong,readonly) NSString * absoluteUrl;
@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,strong,readonly) NSURLRequest * request;
    
-(instancetype) initWithURL:(NSString *) url;
                                 
+(NSString *) pathWithURI:(NSString *) uri;
+(NSString *) cacheKeyWithURL:(NSString *) url;
+(NSString *) cachePathWithURL:(NSString *) url;
+(NSString *) cacheTmpPathWithURL:(NSString *) url;

+(NSString *) encodeURL:(NSString *) url;

+(NSString *) decodeURL:(NSString *) url;

@end

@interface KKHttpBody : NSObject {
 
}
    
@property(nonatomic,strong,readonly) NSString * contentType;
@property(nonatomic,strong,readonly) NSData * data;
    
-(void) add:(NSString *) key value:(NSString *) value;
-(void) add:(NSString *) key data:(NSData *) data type:(NSString *) type name:(NSString *) name;

@end

@protocol KKHttpTask <JSExport>

-(void) cancel;

@end

@interface KKHttpTask : NSObject<KKHttpTask> {
    
}
    
@property(nonatomic,assign,readonly) NSUInteger identity;
@property(nonatomic,strong,readonly) KKHttpOptions * options;
@property(nonatomic,strong,readonly) NSString * key;
@property(nonatomic,weak,readonly) id weakObject;
    
-(void) cancel;
    
@end

@protocol KKHttp<NSObject>

-(id<KKHttpTask>) send:(KKHttpOptions *) options weakObject:(id) weakObject ;

-(void) cancel:(id) weakObject;

@end

typedef void (^KKHttpImageCallback)(UIImage * image);

#ifdef __cplusplus
extern "C" {
#endif
    
extern dispatch_queue_t KKHttpIODispatchQueue(void);

#ifdef __cplusplus
}
#endif

@interface KKHttp : NSObject<KKHttp>

@property(nonatomic,strong,readonly) NSURLSession * session;
   
-(instancetype) init;
    
-(instancetype) initWithConfiguration:(NSURLSessionConfiguration *) configuration;
    
-(id<KKHttpTask>) send:(KKHttpOptions *) options weakObject:(id) weakObject ;

-(id<KKHttpTask>) get:(NSString *) url data:(id) data type:(NSString *) type onload:(KKHttpOnLoad) onload onfail:(KKHttpOnFail) onfail weakObject:(id) weakObject;
    
-(id<KKHttpTask>) post:(NSString *) url data:(id) data type:(NSString *) type onload:(KKHttpOnLoad) onload onfail:(KKHttpOnFail) onfail weakObject:(id) weakObject;
  
-(void) cancel:(id) weakObject;
    
+(id<KKHttp>) main;

+(UIImage *) imageWithURL:(NSString *) url;
    
+(BOOL) imageWithURL:(NSString *) url callback:(KKHttpImageCallback) callback;

+(NSString *) stringValue:(id) value defaultValue:(NSString *) defaultValue;

+(NSString *) userAgent;

+(void) setUserAgent:(NSString *)userAgent;

@end
