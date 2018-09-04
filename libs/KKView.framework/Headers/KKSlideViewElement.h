//
//  KKSlideViewElement.h
//  KKView
//
//  Created by zhanghailong on 2018/5/24.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <KKView/KKScrollViewElement.h>
#import <KKView/KKElementView.h>

@interface KKSlideCurElement : KKElement

@end

@interface KKSlideViewElement : KKScrollViewElement

@property(nonatomic,strong,readonly) KKViewElement * curElement;
@property(nonatomic,strong,readonly) KKElementView * curElementView;

@end
