//
//  KKElement.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKView/KKEvent.h>

@class KKElement;

@interface KKElementEvent: KKEvent

@property(nonatomic,strong,readonly) KKElement * element;
@property(nonatomic,assign,getter = isCancelBubble) BOOL cancelBubble;
@property(nonatomic,strong) NSDictionary * data;

-(instancetype) initWithElement:(KKElement *) element;

@end

@interface KKElement : KKEventEmitter

@property(nonatomic,strong,readonly) KKElement * firstChild;
@property(nonatomic,strong,readonly) KKElement * lastChild;
@property(nonatomic,strong,readonly) KKElement * nextSibling;
@property(nonatomic,weak,readonly) KKElement * prevSibling;
@property(nonatomic,weak,readonly) KKElement * parent;
@property(nonatomic,assign,readonly) NSInteger levelId;
@property(nonatomic,assign,readonly) NSInteger depth;

-(void) append:(KKElement * ) element;
-(void) before:(KKElement * ) element;
-(void) after:(KKElement * ) element;
-(void) remove;

-(void) appendTo:(KKElement * ) element;
-(void) beforeTo:(KKElement * ) element;
-(void) afterTo:(KKElement * ) element;

-(void) willRemoveChildren:(KKElement *) element;
-(void) didAddChildren:(KKElement *) element;

-(void) changedKeys:(NSSet *) keys;

-(void) changedKey:(NSString *) key;

-(NSSet *) keys;

-(NSString *) get:(NSString *) key;

-(void) set:(NSString *) key value:(NSString *) value;

-(void) setAttrs:(NSDictionary *) attrs;

-(void) setStyle:(NSDictionary *) style forStatus:(NSString *) status;

-(void) setCSSStyle:(NSString *) cssStyle forStatus:(NSString *) status;

-(NSString *) status;

-(void) setStatus:(NSString *) status;

-(NSMutableDictionary *) data;

-(BOOL) hasEventBubble:(NSString *) name;

-(void) recycle;

@end
