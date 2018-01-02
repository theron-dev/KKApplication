//
//  KKWindowPageController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <KKApplication/KKPageController.h>

@interface KKWindowPageController : KKPageController<KKViewController>

-(void) showInView:(UIView *) view;

-(void) show;

-(void) close;

-(void) closeAfterDelay:(NSTimeInterval) afterDelay;

@end
