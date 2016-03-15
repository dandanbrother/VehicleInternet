//
//  VICarInfoModel.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VICarInfoModel.h"

@implementation VICarInfoModel

- (instancetype)initWithDict:(NSDictionary *)dictionary {
    if (self = [super init]) {
//        self.carBrand = dictionary[@"carBrand"];
//        self.licenseNum = dictionary[@"licenseNum"];
//        self.engineNum = dictionary[@"engineNum"];
        [self setValuesForKeysWithDictionary:dictionary];
    
    }
    return self;
}

+ (instancetype)carInfoWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}


@end
