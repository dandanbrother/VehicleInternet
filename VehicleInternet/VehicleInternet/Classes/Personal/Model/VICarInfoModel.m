//
//  VICarInfoModel.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VICarInfoModel.h"

@implementation VICarInfoModel

@dynamic carBrand,symbol,model,licenseNum,engineNum,doorsNum,seatsNum,mileage,petrol,isEngineGood,isTransmissionGood,isLightGood;

- (instancetype)initWithDict:(NSDictionary *)dictionary {
    if (self = [super init]) {

        [self setValuesForKeysWithDictionary:dictionary];
    
    }
    return self;
}

+ (instancetype)carInfoWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+ (NSString *)parseClassName {
    return @"VICarInfoModel";
}

@end
