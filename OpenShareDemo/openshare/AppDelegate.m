//
//  AppDelegate.m
//  openshare
//
//  Created by LiuLogan on 15/5/20.
//  Copyright (c) 2015年 OpenShare http://openshare.gfzj.us/. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenShareHeader.h"
#import "ViewController.h"
#import <objc/runtime.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //第一步：注册key
    [OpenShare connectQQWithAppId:@"1103194207"];
    [OpenShare connectWeiboWithAppKey:@"402180334"];
    [OpenShare connectWeixinWithAppId:@"wxd930ea5d5a258f4f"];
    [OpenShare connectRenrenWithAppId:@"228525" AndAppKey:@"1dd8cba4215d4d4ab96a49d3058c1d7f"];
    [OpenShare connecYixinWithAppId:@"yx61f820ddf9734710932d0ba31e0fa144"];
    [OpenShare connectAlipay];//支付宝参数都是服务器端生成的，这里不需要key.
    
    [self swizzleOpenUrl];
    [self swizzlePasteboard];
    [self swizzlePasteboardGetData];
    [self swizzlePasteboardSetData];
    
    //添加demo ui
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController=[[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //第二步：添加回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }
    //这里可以写上其他OpenShare不支持的客户端的回调，比如支付宝等。
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//对UIApplication的openURL:方法进行hook
-(void)swizzleOpenUrl{
    SEL openUrlSEL=@selector(openURL:);
    BOOL (*openUrlIMP)(id,SEL,id) =(BOOL(*)(id,SEL,id))[UIApplication instanceMethodForSelector:openUrlSEL];
    static int count=0;
    BOOL (^myOpenURL)(id SELF,NSURL * url)=^(id SELF,NSURL *url){
        NSLog(@"\n----------open url: %d----------\n%@\n%@\n",count++,url,@"\n"/*[NSThread callStackSymbols]*/);
        
        return (BOOL)openUrlIMP(SELF,openUrlSEL,url);
    };
    class_replaceMethod([UIApplication class], openUrlSEL, imp_implementationWithBlock(myOpenURL), NULL);
}
//pasteboardWithName:create:方法进行hook，注意这是一个类方法
-(void)swizzlePasteboard{
    SEL pasteboardWithNameSEL=@selector(pasteboardWithName:create:);
    UIPasteboard* (*pasteboardWithNameIMP)(id,SEL,id,BOOL) =(UIPasteboard* (*)(id,SEL,id,BOOL))[UIPasteboard methodForSelector:pasteboardWithNameSEL];
    
    static int count=0;
    UIPasteboard* (^mypasteboardWithName)(id SELF,NSString *name,BOOL create)=^(id SELF,NSString *name,BOOL create){
        NSLog(@"\n----------pasteboardWithName: %d----------\n%@\n%d\n",count++,name,create);
        return (UIPasteboard*)pasteboardWithNameIMP(SELF,pasteboardWithNameSEL,name,create);
    };
    class_replaceMethod(/*类方法hook http://stackoverflow.com/a/3267898/3825920*/object_getClass((id)[UIPasteboard class]), pasteboardWithNameSEL, imp_implementationWithBlock(mypasteboardWithName), NULL);
}

//粘贴板setData:forPasteboardType:
-(void)swizzlePasteboardSetData{
    SEL swizzlePasteboardSetDataSEL=@selector(setData:forPasteboardType:);
    void (*swizzlePasteboardSetDataIMP)(id,SEL,id,id)=(void(*)(id,SEL,id,id))[UIPasteboard instanceMethodForSelector:swizzlePasteboardSetDataSEL];
    
    static int count=0;
    void (^mypasteboardSetData)(id SELF,NSData *data,NSString *type)=^(id SELF,NSData *data,NSString *type){
        
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"\n----------swizzlePasteboardSetData: %d----------\n%@\n%@\n%@\n",count++,[((UIPasteboard *)SELF) name], type,dict);
        swizzlePasteboardSetDataIMP(SELF,swizzlePasteboardSetDataSEL,data,type);
        
    };
    class_replaceMethod([UIPasteboard class], swizzlePasteboardSetDataSEL, imp_implementationWithBlock(mypasteboardSetData), NULL);
}

//粘贴板 dataForPasteboardType:
-(void)swizzlePasteboardGetData{
    SEL swizzlePasteboardGetDataSEL=@selector(dataForPasteboardType:);
    NSData* (*swizzlePasteboardGetDataIMP)(id,SEL,id)=(NSData*(*)(id,SEL,id))[UIPasteboard instanceMethodForSelector:swizzlePasteboardGetDataSEL];
    
    static int count=0;
    NSData* (^mypasteboardGetData)(id SELF,NSString *type)=^(id SELF,NSString *type){//
        NSData *ret=(NSData*)swizzlePasteboardGetDataIMP(SELF,swizzlePasteboardGetDataSEL,type);
        //NSLog(@"\n----------pasteboardGetData: %d----------\n%@\n%@\n%@\n%@",count++,[((UIPasteboard *)SELF) name], type,ret,ret);
        return ret;
    };
    class_replaceMethod([UIPasteboard class], swizzlePasteboardGetDataSEL, imp_implementationWithBlock(mypasteboardGetData), NULL);
}


@end
