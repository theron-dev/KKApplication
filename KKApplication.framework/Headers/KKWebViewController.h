//
//  KKWebViewController.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/29.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKApplication/KKPageViewController.h>
#import <WebKit/WebKit.h>

@interface KKApplication (KKWebViewController)

@property(nonatomic,strong) WKProcessPool * processPool;

@end



@interface KKWebViewController : UIViewController<KKViewController,WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) IBOutlet UIProgressView * progressView;
@property(nonatomic,strong) IBOutlet WKWebView * webView;
@property(nonatomic,strong) NSString * url;
@property(nonatomic,strong) NSArray<NSHTTPCookie*> * cookies;
@property(nonatomic,strong) WKProcessPool * processPool;

-(BOOL) openURL:(NSURL *) url;

-(WKWebView *) loadWebView;

-(WKWebViewConfiguration *) loadWebViewConfiguration;

-(IBAction) doCloseAction:(id)sender;

-(NSURLRequest *) willLoadRequestWithURL:(NSURL *) url;

@end
