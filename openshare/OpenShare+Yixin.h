//
//  OpenShare+Yixin.h
//  openshare
//
//  Created by Wupeng on 6/3/16.
//  Copyright © 2016 OpenShare http://openshare.gfzj.us/. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Yixin)
+(void)connecYixinWithAppId:(NSString *)appId;
+(BOOL)isYixinInstalled;
+(void)shareToYixinSession:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
+(void)shareToYixinTimeline:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;
@end
