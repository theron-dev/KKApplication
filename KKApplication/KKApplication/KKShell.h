//
//  KKShell.h
//  KKApplication
//
//  Created by zhanghailong on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKApplication/KKApp.h>
#import <KKApplication/KKAppStorage.h>
#import <KKApplication/KKProtocol.h>
#import <KKApplication/KKAppLoading.h>

@class KKShell;

typedef void (^KKShellOpenApplication)(KKApplication * app);

@protocol KKShellDelegate

@optional

-(BOOL) KKShell:(KKShell *) shell open:(NSURL *) url path:(NSString *) path appInfo:(NSDictionary *) appInfo openApplication:(KKShellOpenApplication) openApplication;

-(BOOL) KKShell:(KKShell *) shell openApplication:(KKApplication *) application;

-(void) KKShell:(KKShell *) shell willLoading:(NSURL *) url;

-(void) KKShell:(KKShell *) shell options:(KKHttpOptions *) options;

-(void) KKShell:(KKShell *) shell loading:(NSURL *) url path:(NSString *) path count:(NSInteger) count totalCount:(NSInteger) totalCount;

-(void) KKShell:(KKShell *) shell loading:(NSURL *) url path:(NSString *) path appInfo:(id) appInfo;

-(void) KKShell:(KKShell *) shell didLoading:(NSURL *) url path:(NSString *) path;

-(void) KKShell:(KKShell *)shell didFailWithError:(NSError *) error url:(NSURL *) url;

-(BOOL) KKShell:(KKShell *)shell application:(KKApplication *) application openAction:(NSDictionary *) action;

-(UIViewController *) KKShell:(KKShell *)shell application:(KKApplication *) application viewController:(NSDictionary *) action;

-(void) KKShell:(KKShell *)shell application:(KKApplication *) application willSend:(KKHttpOptions *) options ;

-(id<KKHttpTask>) KKShell:(KKShell *)shell application:(KKApplication *) application send:(KKHttpOptions *) options weakObject:(id) weakObject;

-(BOOL) KKShell:(KKShell *)shell application:(KKApplication *) application cancel:(id) weakObject;

-(BOOL) KKShell:(KKShell *)shell application:(KKApplication *) application openViewController:(UIViewController *) viewController action:(NSDictionary *) action;


@end

@interface KKShell : KKAppStorage<KKApplicationDelegate>

@property(nonatomic,strong) KKProtocol * protocol;
@property(nonatomic,weak) id<KKShellDelegate> delegate;
@property(nonatomic,strong) KKApplication * mainApplication;

-(void) open:(NSURL *) url;

-(void) open:(NSURL *) url query:(NSDictionary *) query;

-(void) open:(NSURL *) url query:(NSDictionary *) query checkUpdate:(BOOL) checkUpdate;

-(BOOL) has:(NSURL *) url;

-(void) update:(NSURL *) url;

-(KKAppLoading *) isLoading:(NSURL *) url;

-(void) openApplication:(KKApplication *) app;

-(void) openApplication:(KKApplication *) app query:(NSDictionary *) query;

+(KKShell *) main;

@end
