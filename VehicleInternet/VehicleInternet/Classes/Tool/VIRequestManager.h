//
//  VIRequestManager.h
//  网络请求测试
//
//  Created by 倪丁凡 on 16/5/5.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CallBack)(NSDictionary *data);

@interface VIRequestManager : NSObject


- (void)requestIllegalQueryWithlisenceNo:(NSString *)lisenceNo frameNo:(NSString *)frameNo engineNo:(NSString *)engineNo callBackBlock:(CallBack)callback;
@end
