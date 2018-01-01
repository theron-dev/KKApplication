//
//  KKShell.h
//  KKApplication
//
//  Created by hailong11 on 2017/12/31.
//  Copyright © 2017年 kkmofang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KKApplication/KKApp.h>

@class KKShell;

typedef void (^KKShellOpenApplication)(KKApplication * app);

@protocol KKShellDelegate

@optional

-(BOOL) KKShell:(KKShell *) shell open:(NSURL *) url path:(NSString *) path appInfo:(NSDictionary *) appInfo openApplication:(KKShellOpenApplication) openApplication;

-(BOOL) KKShell:(KKShell *) shell openApplication:(KKApplication *) application;

-(void) KKShell:(KKShell *) shell willLoading:(NSURL *) url;

-(void) KKShell:(KKShell *) shell options:(KKHttpOptions *) options;

-(void) KKShell:(KKShell *) shell didLoading:(NSURL *) url path:(NSString *) path;

-(void) KKShell:(KKShell *)shell didFailWithError:(NSError *) error url:(NSURL *) url;

@end

@interface KKShell : NSObject<KKApplicationDelegate>

@property(nonatomic,weak) id<KKShellDelegate> delegate;

-(void) open:(NSURL *) url;

-(BOOL) has:(NSURL *) url;

-(void) update:(NSURL *) url;

+(KKShell *) main;

@end
