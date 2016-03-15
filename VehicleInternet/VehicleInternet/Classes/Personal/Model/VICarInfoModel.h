//
//  VICarInfoModel.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICarInfoModel : NSObject
/**
 *  汽车品牌、标志、型号、车牌号码、发动机号、车身级别（几门几座）、里程数、汽油量（%）、发动机性能（好、异常）、变速器性能（好、异常），车灯（好、坏）。
 */
@property (nonatomic,copy) NSString *carBrand;
@property (nonatomic,copy) NSString *licenseNum;
@property (nonatomic,copy) NSString *engineNum;

+ (instancetype)carInfoWithDict:(NSDictionary *)dict;
@end
