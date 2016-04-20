//
//  VIProtectCarInfoEwmController.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/19.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VICarInfoModel;

@interface VIProtectCarInfoEwmController : UIViewController
+ (instancetype)ewmShownWithCarInfo:(VICarInfoModel *)carInfo;

@end
