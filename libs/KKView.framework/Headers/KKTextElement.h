//
//  KKTextElement.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>

@interface KKImgElement : KKElement

@property(nonatomic,assign) struct KKEdge margin;
@property(nonatomic,assign) struct KKPixel width;
@property(nonatomic,assign) struct KKPixel height;
@property(nonatomic,strong,readonly) NSString * src;
@property(nonatomic,strong) UIImage * image;
@property(nonatomic,assign,readonly) CGRect bounds;

@end

@interface KKSpanElement: KKElement

@property(nonatomic,assign) struct KKPixel letterSpacing;
@property(nonatomic,strong) UIColor * color;
@property(nonatomic,strong) UIFont * font;
@property(nonatomic,strong,readonly) NSString * text;

@property(nonatomic,strong) UIColor * strokeColor;
@property(nonatomic,assign) struct KKPixel strokeSpacing;
@property(nonatomic,assign) enum KKTextDecoration textDecoration;

@end

@interface KKTextElement : KKViewElement

@property(nonatomic,assign) struct KKPixel lineSpacing;
@property(nonatomic,assign) struct KKPixel paragraphSpacing;
@property(nonatomic,assign) struct KKPixel letterSpacing;
@property(nonatomic,assign) struct KKPixel baseline;
@property(nonatomic,assign) NSTextAlignment textAlign;
@property(nonatomic,strong) UIColor * color;
@property(nonatomic,strong) UIFont * font;
@property(nonatomic,strong,readonly) NSAttributedString * attributedString;
@property(nonatomic,strong,readonly) NSString * text;

@property(nonatomic,strong) UIColor * strokeColor;
@property(nonatomic,assign) struct KKPixel strokeSpacing;
@property(nonatomic,assign) enum KKTextDecoration textDecoration;

-(CGRect) bounds:(CGSize) size;

@end
