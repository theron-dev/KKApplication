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
        KKPixelTypeAuto,KKPixelTypePercent,KKPixelTypePX,KKPixelTypeRPX
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
    
    extern CGFloat KKPixelValue(struct KKPixel v ,CGFloat baseOf,CGFloat defaultValue);
    
    extern BOOL KKPixelIsValue(NSString * value);
    
    extern NSString * KKStringValue(id value);
    
    extern BOOL KKBooleanValue(id value);
    
    extern enum KKVerticalAlign KKVerticalAlignFromString(NSString * value);
    
    NSString * NSStringFromKKPixel(struct KKPixel v);
    
    NSString * NSStringFromKKEdge(struct KKEdge v);
    
#ifdef   __cplusplus
}
#endif

