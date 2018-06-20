//
//  KKPixel.h
//  KKView
//
//  Created by hailong11 on 2017/12/25.
//  Copyright © 2017年 mofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
  
    
    enum KKPixelType {
        KKPixelTypeAuto,KKPixelTypePercent,KKPixelTypePX,KKPixelTypeRPX,KKPixelTypeVW,KKPixelTypeVH
    };
    
    struct KKPixel {
        CGFloat value;
        enum KKPixelType type;
    };
    
    struct KKEdge {
        struct KKPixel top,right,bottom,left;
    };
    
    enum KKVerticalAlign {
        KKVerticalAlignTop,KKVerticalAlignMiddle,KKVerticalAlignBottom
    };
    
    enum KKPosition {
        KKPositionNone,KKPositionTop,KKPositionBottom,KKPositionLeft,KKPositionRight
    };
    
    extern enum KKPosition KKPositionFromString(NSString * value);
    
    extern struct KKPixel KKPixelFromString(NSString * value);
    
    extern struct KKEdge KKEdgeFromString(NSString * value);
    
    extern CGFloat KKPixelUnitPX(void);
    extern CGFloat KKPixelUnitRPX(void);
    extern CGFloat KKPixelUnitVW(void);
    extern CGFloat KKPixelUnitVH(void);
    
    extern CGFloat KKPixelValue(struct KKPixel v ,CGFloat baseOf,CGFloat defaultValue);
    
    extern BOOL KKPixelIsValue(NSString * value);
    
    extern NSString * KKStringValue(id value);
    
    extern BOOL KKBooleanValue(id value);
    
    extern enum KKVerticalAlign KKVerticalAlignFromString(NSString * value);
    
    extern NSTextAlignment KKTextAlignmentFromString(NSString * value);
    
    NSString * NSStringFromKKPixel(struct KKPixel v);
    
    NSString * NSStringFromKKEdge(struct KKEdge v);
    
    extern CATransform3D KKTransformFromString(NSString * value);
    
    enum KKTextDecoration {
        KKTextDecorationNone,KKTextDecorationUnderline,KKTextDecorationLineThrough
    };
    
    enum KKTextDecoration KKTextDecorationFromString(NSString * value);
    
    
#ifdef   __cplusplus
}
#endif

