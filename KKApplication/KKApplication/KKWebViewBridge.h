//
//  KKWebViewBridge.h
//  KKApplication
//
//  Created by hailong11 on 2018/1/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import <KKView/KKView.h>

@protocol KKWebViewBridge;

@protocol KKWebViewBridgeViewController <NSObject>

@property(nonatomic,assign,getter=isTopbarHidden) BOOL topbarHidden;
@property(nonatomic,strong,readonly) UIView * contentView;
@property(nonatomic,strong) NSMutableSet * elementKeys;
@property(nonatomic,strong) NSMutableDictionary * elements;
@property(nonatomic,strong) KKBodyElement * bodyElement;

-(void) removeElement:(KKElement *) element;

@optional

-(BOOL) KKWebViewBridgeCommit:(id<KKWebViewBridge>) gridge;

-(BOOL) KKWebViewBridgeClose:(id<KKWebViewBridge>) gridge;

-(BOOL) KKWebViewBridge:(id<KKWebViewBridge>) gridge gesture:(NSDictionary *) gesture;

-(BOOL) KKWebViewBridge:(id<KKWebViewBridge>) gridge style:(NSString *) name data :(NSDictionary *) data;

@end

@protocol KKWebViewBridge <JSExport>

@property(nonatomic,strong) JSValue * onappbackground;
@property(nonatomic,strong) JSValue * onappforeground;
@property(nonatomic,strong) JSValue * onevent;

JSExportAs(add,
           -(void) add:(NSString *) elementId name:(NSString *) name attrs:(NSDictionary *) attrs parentId:(NSString *) parentId
);

JSExportAs(remove,
           -(void) remove:(NSString *) elementId
           );

JSExportAs(set,
           -(void) set:(NSString *) elementId key:(NSString *) key value:(NSString *) value
           );

JSExportAs(on,
           -(void) on:(NSString *) elementId name:(NSString *) name
           );

JSExportAs(off,
           -(void) off:(NSString *) elementId name:(NSString *) name
           );

-(void) commit;


JSExportAs(style,
           -(void) style:(NSString *) name data:(NSDictionary *) data
           );

-(void) close;

JSExportAs(gesture,
           -(void) gesture:(NSDictionary *) gesture
           );

@end

typedef void (^KKWebViewBridgeOnEvent)(NSString * elementId,NSString * name,id data);

@interface KKWebViewBridge : NSObject<KKWebViewBridge>

@property(nonatomic,strong) KKWebViewBridgeOnEvent onEvent;
@property(nonatomic,weak,readonly) UIViewController<KKWebViewBridgeViewController> * viewController;

-(instancetype) initWithViewController:(UIViewController<KKWebViewBridgeViewController> *) viewController;


@end
