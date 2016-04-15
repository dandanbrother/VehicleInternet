//
//  VICarEwmController.h
//  VehicleInternet
//
//  Created by joker on 16/4/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VICarInfoModel;

@interface VICarEwmController : UIViewController
+ (instancetype)ewmShownWithCarInfo:(VICarInfoModel *)carInfo;
@end
