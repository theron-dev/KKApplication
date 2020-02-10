//
//  KKPageDocument.h
//  KKApplication
//
//  Created by hailong11 on 2019/6/10.
//  Copyright © 2019 kkmofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <KKView/KKView.h>

@protocol KKPageDocument<JSExport>

JSExportAs(create,
           -(void) create:(NSString *) name elementId:(NSString *) elementId
           );

JSExportAs(recycle,
           -(void) recycle:(NSString *)elementId
           );

JSExportAs(add,
           -(void) add:(NSString *)elementId pid:(NSString *) pid
           );

JSExportAs(remove,
           -(void) remove:(NSString *)elementId
           );

JSExportAs(before,
           -(void) before:(NSString *)elementId pid:(NSString *) pid
           );

JSExportAs(after,
           -(void) after:(NSString *)elementId pid:(NSString *) pid
           );

JSExportAs(set,
           -(void) set:(NSString *)elementId key:(NSString *) key value:(NSString *) value
           );

JSExportAs(emit,
           -(void) emit:(NSString *)elementId name:(NSString *) name data:(NSDictionary *) data
           );

JSExportAs(on,
           -(void) on:(NSString *)elementId name:(NSString *) name fn:(JSValue *) fn
           );

JSExportAs(off,
           -(void) off:(NSString *)elementId name:(NSString *) name
           );

@end


@interface KKPageDocument : NSObject<KKPageDocument>

@property(nonatomic,strong) KKViewContext * viewContext;

-(KKElement *) elementById:(NSString *) elementId;

-(void) setElement:(KKElement *) element forElementId:(NSString *) elementId;

-(void) recycle;

@end
