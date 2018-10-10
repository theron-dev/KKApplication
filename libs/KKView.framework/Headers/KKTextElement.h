//
//  KKTextElement.h
//  KKView
//
//  Created by zhanghailong on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>

@protocol KKTextElement<NSObject>

@property(nonatomic,assign) struct KKPixel lineSpacing;
@property(nonatomic,assign) struct KKPixel paragraphSpacing;
@property(nonatomic,assign) struct KKPixel letterSpacing;
@property(nonatomic,assign) struct KKPixel baseline;
@property(nonatomic,strong) UIColor * color;
@property(nonatomic,strong) UIFont * font;
@property(nonatomic,strong) UIColor * strokeColor;
@property(nonatomic,assign) struct KKPixel strokeSpacing;
@property(nonatomic,assign) enum KKTextDecoration textDecoration;

@optional
@property(nonatomic,assign) NSTextAlignment textAlign;

@end

extern NSDictionary * KKTextElementStringAttribute(KKElement<KKTextElement> * e,...);
extern CGSize KKTextElementLayout(KKViewElement * element);

@interface KKImgElement : KKElement

@property(nonatomic,assign) struct KKEdge margin;
@property(nonatomic,assign) struct KKPixel width;
@property(nonatomic,assign) struct KKPixel height;
@property(nonatomic,strong,readonly) NSString * src;
@property(nonatomic,strong) UIImage * image;
@property(nonatomic,assign,readonly) CGRect bounds;

@end

@interface KKSpanElement: KKElement<KKTextElement>

@property(nonatomic,strong,readonly) NSString * text;

@end

@interface KKTextElement : KKViewElement<KKTextElement>

@property(nonatomic,strong,readonly) NSAttributedString * attributedString;
@property(nonatomic,strong,readonly) NSString * text;


-(CGRect) bounds:(CGSize) size;

@end
