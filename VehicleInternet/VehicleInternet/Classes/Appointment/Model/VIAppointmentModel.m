//
//  VIAppointmentModel.m
//  VehicleInternet
//
//  Created by joker on 16/3/24.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAppointmentModel.h"

@implementation VIAppointmentModel

@dynamic carName,carOwnerName,time,ownerID,petrolStation,petrolType,petrolAmount,plateNum,isPayed;

+ (NSString *)parseClassName
{
    return @"VIAppointmentModel";
}

@end
