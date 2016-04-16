//
//  VIAppointmentModel.h
//  VehicleInternet
//
//  Created by joker on 16/3/24.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface VIAppointmentModel : AVObject <AVSubclassing>


@property (nonatomic,copy) NSString *carName;

@property (nonatomic,copy) NSString *plateNum;

@property (nonatomic,copy) NSString *carOwnerName;

@property (nonatomic,copy) NSString *time;

@property (nonatomic,copy) NSString *isPayed;


/** 标识符 */
@property (nonatomic,copy) NSString * ownerID;

@property (nonatomic,copy) NSString *petrolStation;

@property (nonatomic,copy) NSString *petrolType;

@property (nonatomic,copy) NSString *petrolAmount;













@end
