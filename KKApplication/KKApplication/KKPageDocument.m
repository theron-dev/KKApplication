//
//  KKPageDocument.m
//  KKApplication
//
//  Created by hailong11 on 2019/6/10.
//  Copyright © 2019 kkmofang.cn. All rights reserved.
//

#import "KKPageDocument.h"

@interface KKPageDocument() {
    NSMutableDictionary * _elements;
}
@end

@implementation KKPageDocument

-(void) recycle {
    NSEnumerator * keyEnum = [_elements keyEnumerator];
    NSString * key  = nil;
    while((key = [keyEnum nextObject])) {
        KKElement * e = [_elements objectForKey:key];
        [e recycle];
    }
    [_elements removeAllObjects];
}


-(void) create:(NSString *) name elementId:(NSString *) elementId {
    
    if(elementId == nil || name == nil) {
        return;
    }
    
    KKElement * e = nil;
    
    Class isa =[[KKViewContext defaultElementClass] objectForKey:name];
    
    if(isa != nil) {
        e = [[isa alloc] init];
    }
    
    if(e == nil) {
        e = [[KKElement alloc] init];
    }
    
    [self setElement:e forElementId:elementId];
    
}

-(void) recycle:(NSString *)elementId {
    
    if(elementId == nil) {
        return;
    }
    
    KKElement * p = [_elements objectForKey:elementId];
    
    [_elements removeObjectForKey:elementId];
    
    [p recycle];
    
}

-(void) add:(NSString *)elementId pid:(NSString *) pid {
    if(elementId == nil || pid == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    KKElement * p = [_elements objectForKey:pid];
    if(e && p) {
        [p append:e];
    }
}

-(void) remove:(NSString *)elementId {
    if(elementId == nil ) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    [e remove];
}

-(void) before:(NSString *)elementId pid:(NSString *) pid {
    if(elementId == nil || pid == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    KKElement * p = [_elements objectForKey:pid];
    if(e && p) {
        [p before:e];
    }
}

-(void) after:(NSString *)elementId pid:(NSString *) pid {
    if(elementId == nil || pid == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    KKElement * p = [_elements objectForKey:pid];
    if(e && p) {
        [p after:e];
    }
}

-(void) set:(NSString *)elementId key:(NSString *) key value:(NSString *) value {
    if(elementId == nil || key == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    [e set:key value:value];
}

-(void) emit:(NSString *)elementId name:(NSString *) name data:(NSDictionary *) data {
    if(elementId == nil || name == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    if(e != nil) {
        KKElementEvent * event = [[KKElementEvent alloc] initWithElement:e];
        if([data isKindOfClass:[NSDictionary class]]) {
            event.data = [data mutableCopy];
        }
        [e emit:name event:event];
    }
    
}

-(void) on:(NSString *)elementId name:(NSString *) name fn:(JSValue *) fn {
    if(elementId == nil || name == nil || fn == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    if(e != nil) {
        [e on:name fn:^(KKEvent *event, void *context) {
            if([event isKindOfClass:[KKElementEvent class]]) {
                @try {
                    
                    NSMutableArray * args = [NSMutableArray arrayWithCapacity:4];
                
                    id data = [(KKElementEvent *) event data];
                    
                    if(data) {
                        [args addObject:data];
                    }
                    
                    [fn callWithArguments:args];
                }
                @catch(NSException * ex) {
                    NSLog(@"[KK] [KKPageDocument] %@",ex);
                }
            }
        } context:(__bridge void *) self];
    }
}

-(void) off:(NSString *)elementId name:(NSString *) name {
    if(elementId == nil) {
        return;
    }
    KKElement * e = [_elements objectForKey:elementId];
    if(e != nil) {
        [e off:name fn:nil context:(__bridge void *) self];
    }
}

-(KKElement *) elementById:(NSString *) elementId {
    return [_elements objectForKey:elementId];
}

-(void) setElement:(KKElement *) element forElementId:(NSString *) elementId {

    if(_elements == nil) {
        _elements = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    [_elements setObject:element forKey:elementId];
}

@end
