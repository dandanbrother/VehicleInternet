//
//  VIUserModel.h
//  VehicleInternet
//
//  Created by joker on 16/4/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface VIUserModel : AVUser <AVSubclassing>


@property (nonatomic,copy) NSString *nickName;

@end
