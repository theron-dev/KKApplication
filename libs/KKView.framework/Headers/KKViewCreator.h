//
//  KKViewCreator.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKElement.h>
#import <KKObserver/KKObserver.h>


typedef void (^KKViewChildren)(KKElement * p, KKObserver * data);

void KKView(Class elementClass, NSDictionary * attrs, KKElement * p, KKObserver * data,KKViewChildren children);

