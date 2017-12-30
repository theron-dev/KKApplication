//
//  KKJSHttp.h
//  KKHttp
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@protocol KKHttp;
@class KKHttpOptions;
@class KKHttp;
@protocol KKHttpTask;
@protocol KKJSHttpOptions;

@protocol KKJSHttp<JSExport>

JSExportAs(send,
-(id<KKHttpTask>) send:(JSValue *) options
);

@end

@interface KKJSHttp : NSObject<KKJSHttp>

@property(nonatomic,strong,readonly) id<KKHttp> http;

-(instancetype) initWithHttp:(id<KKHttp>) http;

-(void) cancel;

@end
