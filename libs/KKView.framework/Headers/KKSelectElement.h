//
//  KKSelectElement.h
//  KKView
//
//  Created by zhanghailong on 2018/9/6.
//  Copyright © 2018年 kkmofang.cn. All rights reserved.
//

#import <KKView/KKViewElement.h>
#import <KKObserver/KKObserver.h>

@protocol KKSelectOption<NSObject>

@property(nonatomic,assign,readonly,getter=isSelected) BOOL selected;
@property(nonatomic,strong,readonly) NSString * value;
@property(nonatomic,strong,readonly) NSString * text;

@end

typedef void (^KKSelectInputViewConfirmFunc)(id<KKSelectOption> option);

@interface KKSelectOptionElement :KKElement<KKSelectOption>

@end

@protocol KKSelectInputView<NSObject>

@property(nonatomic,weak,readonly) UIResponder * inputResponder;

-(void) setOptions:(NSArray<KKSelectOption> *) options confirm:(KKSelectInputViewConfirmFunc) confirm inputResponder:(UIResponder *) inputResponder;

@end

@interface KKSelectElement : KKViewElement

+(UIView<KKSelectInputView> *) defaultInputView;

+(void) setDefaultInputView:(UIView<KKSelectInputView> *) inputView;

@end
