//
//  KKScrollViewElement.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>

@interface KKScrollViewElement : KKViewElement<UIScrollViewDelegate>

@property(nonatomic,assign,readonly) struct KKPixel taptop;
@property(nonatomic,assign,readonly) struct KKPixel tapbottom;

@end
