//
//  KKProtocol.h
//  KKApplication
//
//  Created by hailong11 on 2018/5/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKApplication/KKApp.h>

typedef void (^KKProtocolOpenApplication)(KKApplication * app);

@interface KKProtocol : NSObject

-(void) addOpenApplication:(KKProtocolOpenApplication) openApplication;

-(void) openApplication:(KKApplication *) app;

+(KKProtocol *) main;

@end
