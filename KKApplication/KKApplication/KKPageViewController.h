//
//  KKPageViewController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/28.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKApplication/KKViewController.h>
#import <KKApplication/KKPageController.h>

@interface KKPageViewController : KKViewController

@property(nonatomic,strong) IBOutlet UIView * contentView;
@property(nonatomic,strong,readonly) KKPageController * pageController;


@end
