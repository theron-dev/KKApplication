//
//  KKAnimationElement.h
//  KKView
//
//  Created by 张海龙 on 2018/4/9.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <KKView/KKElement.h>
#import <QuartzCore/QuartzCore.h>

@interface KKAnimationElement : KKElement

@property(nonatomic,strong,readonly) CAAnimation * animation;

@end
