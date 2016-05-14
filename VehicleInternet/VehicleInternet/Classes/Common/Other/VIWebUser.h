//
//  VIWebUser.h
//  VehicleInternet
//
//  Created by joker on 16/5/14.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIWebUser : NSObject

@property (nonatomic,assign) int user_id;

@property (nonatomic,copy) NSString *user_name;

@property (nonatomic,copy) NSString *password;

@property (nonatomic,copy) NSString *phone_number;

@property (nonatomic,copy) NSString *nickName;

@end
