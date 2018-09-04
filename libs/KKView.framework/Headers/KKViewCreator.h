//
//  KKViewCreator.h
//  KKView
//
//  Created by zhanghailong on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKElement.h>
#import <KKObserver/KKObserver.h>


typedef void (^KKViewChildren)(KKElement * p, KKJSObserver * data);

void KKView(Class elementClass, NSDictionary * attrs, KKElement * p, KKJSObserver * data,KKViewChildren children);

