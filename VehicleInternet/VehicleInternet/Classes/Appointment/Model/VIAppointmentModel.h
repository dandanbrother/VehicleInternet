//
//  VIAppointmentModel.h
//  VehicleInternet
//
//  Created by joker on 16/3/24.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface VIAppointmentModel : AVObject <AVSubclassing>

@property (nonatomic,copy) NSString *carOwnerName;

@property (nonatomic)  NSData *time;

@property (nonatomic,copy) NSString * carOwnerID;

@property (nonatomic,copy) NSString *petrolStation;

@property (nonatomic,copy) NSString *petrolType;

@property (nonatomic,copy) NSString *petrolAmount;












@end
