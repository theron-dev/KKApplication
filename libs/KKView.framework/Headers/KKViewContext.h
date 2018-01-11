//
//  KKViewContext.h
//  KKView
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKHttp/KKHttp.h>

@class KKViewContext;

@protocol KKViewContextDelegate

@optional

-(void) KKViewContext:(KKViewContext *) viewContext willSend:(KKHttpOptions *) options ;

-(id<KKHttpTask>) KKViewContext:(KKViewContext *) viewContext send:(KKHttpOptions *) options weakObject:(id) weakObject ;

-(BOOL) KKViewContext:(KKViewContext *) viewContext cancel:(id) weakObject;

-(UIImage *) KKViewContext:(KKViewContext *) viewContext imageWithURI:(NSString * ) uri;

-(BOOL) KKViewContext:(KKViewContext *) viewContext imageWithURI:(NSString * ) uri callback:(KKHttpImageCallback) callback;
    
@end

@interface KKViewContext : NSObject<KKHttp>

@property(nonatomic,weak) id<KKViewContextDelegate> delegate;
@property(nonatomic,strong) NSString * basePath;

-(UIImage *) imageWithURI:(NSString * ) uri;
    
-(BOOL) imageWithURI:(NSString * ) uri callback:(KKHttpImageCallback) callback;

+(void) pushContext:(KKViewContext *) context;

+(KKViewContext *) currentContext;

+(void) popContext;

+(NSMutableDictionary *) defaultElementClass;

+(void) setDefaultElementClass:(Class) elementClass name:(NSString *) name;

@end
