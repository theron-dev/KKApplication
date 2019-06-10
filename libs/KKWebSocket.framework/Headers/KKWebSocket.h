//
//  KKWebSocket.h
//  KKWebSocket
//
//  Created by zhanghailong on 2018/2/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKWebSocket/KKWebSocket.h>
#import <KKWebSocket/KKJSWebSocket.h>

typedef enum KKWebSocketState {
    KKWebSocketStateNone,
    KKWebSocketStateConnecting,
    KKWebSocketStateConnected,
    KKWebSocketStateDisconnecting,
    KKWebSocketStateDisconnected
} KKWebSocketState;

#ifdef __cplusplus
extern "C" {
#endif
    
    extern NSRunLoop * KKWebSocketRunLoop(void);
    extern NSThread * KKWebSocketRunLoopThread(void);
    
#ifdef __cplusplus
}
#endif

@interface KKWebSocket : NSObject

@property(nonatomic,strong) dispatch_queue_t queue;
@property(nonatomic,assign) KKWebSocketState state;
@property(nonatomic,strong,readonly) NSURL * url;
@property(nonatomic, strong) void (^onconnected)(void);
@property(nonatomic, strong) void (^ondisconnected)(NSError*);
@property(nonatomic, strong) void (^ondata)(NSData*);
@property(nonatomic, strong) void (^ontext)(NSString*);
@property(nonatomic,strong,readonly) NSMutableDictionary * headers;
@property(nonatomic,strong,readonly) NSThread * thread;
    
-(instancetype) initWithURL:(NSURL *) url;

-(void) connect;

-(void) disconnect;

-(void) writeData:(NSData *) data;

-(void) writeString:(NSString*)string;

@end
