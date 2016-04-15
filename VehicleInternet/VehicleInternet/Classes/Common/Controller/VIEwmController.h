//
//  VIEwmController.h
//  VehicleInternet
//
//  Created by joker on 16/4/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VIAppointmentModel;

@interface VIEwmController : UIViewController

+ (instancetype)ewmShownWithAppointment:(VIAppointmentModel *)appointment;

@end
