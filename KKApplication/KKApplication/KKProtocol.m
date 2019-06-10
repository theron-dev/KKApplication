//
//  KKProtocol.m
//  KKApplication
//
//  Created by zhanghailong on 2018/5/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import "KKProtocol.h"

@interface KKProtocol() {
    NSMutableArray * _openApplications;
}

@end;

@implementation KKProtocol

-(void) addOpenApplication:(KKProtocolOpenApplication) openApplication {
    if(_openApplications == nil) {
        _openApplications = [[NSMutableArray alloc] initWithCapacity:4];
    }
    [_openApplications addObject:openApplication];
}

-(void) openApplication:(KKApplication *) app {
    for(KKProtocolOpenApplication v in _openApplications) {
        v(app);
    }
}

+(KKProtocol *) main {
    static KKProtocol * v = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [[KKProtocol alloc] init];
    });
    return v;
}

@end
