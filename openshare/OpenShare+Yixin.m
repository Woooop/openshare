//
//  OpenShare+Yixin.m
//  openshare
//
//  Created by Wupeng on 6/3/16.
//  Copyright © 2016 OpenShare http://openshare.gfzj.us/. All rights reserved.
//

#import "OpenShare+Yixin.h"

@implementation OpenShare (Yixin)

static NSString* schema=@"Yixin";
static NSString* AppId=@"";
//示例代码，注册全局信息
+(void)connecYixinWithAppId:(NSString *)appId{
    AppId = appId;
    [self set:schema Keys:@{@"appid":appId}];
}
//示例代码，判断是否安装，注意客户端的schema需要修改
+(BOOL)isYixinInstalled{
    return [self canOpen:@"yixin://"];
}
//示例代码：聊天，私信
+(void)shareToYixinSession:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail{
    if ([self beginShare:schema Message:msg Success:success Fail:fail]) {
        [self openURL:[self genYixinShareUrl:msg to:0]];
    }
}
//示例代码：朋友圈，新鲜事等
+(void)shareToYixinTimeline:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail{
    if ([self beginShare:schema Message:msg Success:success Fail:fail]) {
        [self openURL:[self genYixinShareUrl:msg to:1]];
    }
}
//示例代码，生成分享链接。
+(NSString*)genYixinShareUrl:(OSMessage*)msg to:(int)shareTo{
    
    NSDictionary *dictAppInfo = @{@"appID" : AppId,@"appIcon" : [self dataWithImage:msg.image],@"appName" : @"青果摄像机"};
    NSDictionary *dictInfoApp = @{AppId:dictAppInfo};
    
    NSDictionary *mediaObject = @{@"mediaType" : @(4), @"webpageUrl" : msg.link};
    NSDictionary *message = @{@"description" : msg.desc , @"mediaObject" : mediaObject, @"thumbData" : msg.thumbnail? [self dataWithImage:msg.thumbnail]:[self dataWithImage:msg.image scale:CGSizeMake(36, 36)], @"title" : msg.title};
    NSDictionary *dictInfoData = @{@"bText" : @(0),@"fromAppID" : AppId,@"message" : message, @"scene" : @(shareTo), @"toAppID" : @"yixinopenapi" , @"type" : @(1)};
//    [[UIPasteboard generalPasteboard] setData:[NSPropertyListSerialization dataWithPropertyList:@{@"dictInfoApp" : dictInfoApp , @"dictInfoData" : dictInfoData} format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil] forPasteboardType:@"pasteBoardDataType"];
    NSMutableDictionary *data = [@{@"dictInfoApp" : dictInfoApp , @"dictInfoData" : dictInfoData} mutableCopy];
    
    [self setGeneralPasteboard:@"pasteBoardDataType" Value:data encoding: OSPboardEncodingKeyedArchiver];
    return @"yixinopenapi://product=yixin";
}
//示例代码，分享，登录成功以后，回调。如果能处理(不管返回结果)就返回YES，否则返回NO，让别人处理。必须实现
+(BOOL)Yixin_handleOpenURL{
    NSURL* url=[self returnedURL];
    if ([url.scheme hasPrefix:@"yx"]) {
        
        NSDictionary *retDic = [NSKeyedUnarchiver unarchiveObjectWithData:[[UIPasteboard generalPasteboard] dataForPasteboardType:@"pasteBoardDataType"]];
        NSDictionary *data = [retDic objectForKey:@"dictInfoData"];
        NSNumber *code = [data objectForKey:@"code"];
        if ([code isEqual:@(0)]) {
            if ([self shareSuccessCallback]) {
                [self shareSuccessCallback]([self message]);
            }
        }
        else{
            if ([self shareFailCallback]) {
                [self shareFailCallback]([self message],nil);
            }
        }
        return YES;
    }
    else{
        return NO;
    }
   
}

@end
