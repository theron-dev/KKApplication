//
//  KKJSWebSocket.h
//  KKWebSocket
//
//  Created by zhanghailong on 2018/5/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@class KKWebSocket;

@protocol KKJSWebSocket<JSExport>

-(void) close;

JSExportAs(on,
           -(void) on:(NSString *) name fn:(JSValue *) fn
           );

JSExportAs(send,
           -(void) send:(JSValue *) data
           );

@end

@interface KKJSWebSocket : NSObject<KKJSWebSocket>

@property(nonatomic,strong,readonly) KKWebSocket * webSocket;

-(instancetype) initWithWebSocket:(KKWebSocket *) webSocket;

-(void) recycle;

@end
