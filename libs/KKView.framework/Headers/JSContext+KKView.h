//
//  JSContext+KKView.h
//  KKView
//
//  Created by hailong11 on 2017/12/27.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <KKView/KKViewCreator.h>

@interface JSContext (KKView)

-(void) KKViewOpenlib:(NSDictionary *) elementClass;

-(void) KKViewOpenlib;

@end
