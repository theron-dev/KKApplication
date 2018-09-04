//
//  KKImageElement.h
//  KKView
//
//  Created by zhanghailong on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>

@interface KKImageElement : KKViewElement

@property(nonatomic,strong,readonly) NSString * src;
@property(nonatomic,strong) UIImage * image;
@property(nonatomic,strong,readonly) NSString * defaultSrc;
@property(nonatomic,strong) UIImage * defaultImage;
@property(nonatomic,strong,readonly) NSString * failSrc;
@property(nonatomic,strong) UIImage * failImage;
@property(nonatomic,strong) NSError * error;

@end
