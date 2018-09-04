//
//  KKQRElement.h
//  KKView
//
//  Created by zhanghailong on 2018/1/1.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>

@interface KKQRElement : KKViewElement

@property(nonatomic,strong,readonly) UIImage * image;

-(void) setNeedsDisplay;

@end
