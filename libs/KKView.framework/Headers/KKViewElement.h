//
//  KKViewElement.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKView/KKElement.h>
#import <KKView/KKPixel.h>
#import <KKView/KKViewContext.h>

@class KKViewElement;

typedef CGSize (* KKViewElementLayout)(KKViewElement * element);

/**
 * 相对布局 "relative"
 */
CGSize KKViewElementLayoutRelative(KKViewElement * element);

/**
 * 流式布局 "flex" 左到右 上到下
 */
CGSize KKViewElementLayoutFlex(KKViewElement * element);

/**
 * 水平布局 "horizontal" 左到右
 */
CGSize KKViewElementLayoutHorizontal(KKViewElement * element);


@interface KKViewElement : KKElement

@property(nonatomic,strong) KKViewContext * viewContext;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) CGSize contentSize;
@property(nonatomic,assign) CGPoint contentOffset;
@property(nonatomic,assign,readonly) struct KKEdge padding;
@property(nonatomic,assign,readonly) struct KKEdge margin;
@property(nonatomic,assign,readonly) struct KKPixel width;
@property(nonatomic,assign,readonly) struct KKPixel minWidth;
@property(nonatomic,assign,readonly) struct KKPixel maxWidth;
@property(nonatomic,assign,readonly) struct KKPixel height;
@property(nonatomic,assign,readonly) struct KKPixel minHeight;
@property(nonatomic,assign,readonly) struct KKPixel maxHeight;
@property(nonatomic,assign,readonly) struct KKPixel left;
@property(nonatomic,assign,readonly) struct KKPixel top;
@property(nonatomic,assign,readonly) struct KKPixel right;
@property(nonatomic,assign,readonly) struct KKPixel bottom;
@property(nonatomic,assign,readonly) enum KKVerticalAlign verticalAlign;
@property(nonatomic,assign,readonly) enum KKPosition position;
@property(nonatomic,assign) CGPoint translate;
@property(nonatomic,assign) KKViewElementLayout layout;
@property(nonatomic,strong) UIView * view;
@property(nonatomic,strong,readonly) NSString * reuse;
@property(nonatomic,strong,readonly) Class viewClass;

-(void) obtainView:(UIView *) view;

-(void) recycleView;

-(void) obtainChildrenView;

-(void) addSubview:(UIView *) view element:(KKViewElement *) element toView:(UIView *) toView;

-(BOOL) isChildrenVisible:(KKViewElement *) element;

-(BOOL) isHidden;

-(void) layoutChildren;

-(void) didLayouted;

-(void) layout:(CGSize) size;


@end

@interface UIView (KKElement)

-(void) KKViewElement:(KKViewElement *) element setProperty:(NSString *) key value:(NSString *) value;

-(void) KKViewElementDidLayouted:(KKViewElement *) element;

-(void) KKElementRecycleView:(KKViewElement *) element;

-(void) KKElementObtainView:(KKViewElement *) element;

@end


