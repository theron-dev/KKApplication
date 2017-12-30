//
//  KKWebViewController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKApplication/KKViewController.h>
#import <WebKit/WebKit.h>

@interface KKWebViewController : KKViewController

@property(nonatomic,strong,readonly) WKWebView * webView;
@property(nonatomic,strong) NSString * url;

@end
