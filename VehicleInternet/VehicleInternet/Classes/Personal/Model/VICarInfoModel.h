//
//  VICarInfoModel.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface VICarInfoModel : AVObject <AVSubclassing>
/**
 *  汽车品牌、标志、型号、车牌号码、发动机号、车身级别（几门几座）、里程数、汽油量（%）、发动机性能（好、异常）、变速器性能（好、异常），车灯（好、坏）。
 */


@property (nonatomic,copy) NSString *ownerID;

/**
*  汽车品牌
*/
@property (nonatomic,copy) NSString *carBrand;


/**
 *  车牌号
 */
@property (nonatomic,copy) NSString *licenseNum;

/**
 *  发动机号
 */
@property (nonatomic,copy) NSString *engineNum;

/**
 *  车身级别，几门几座
 */
@property (nonatomic, assign) NSInteger doorsNum;
@property (nonatomic, assign) NSInteger seatsNum;

/**
 *  里程数
 */
@property (nonatomic, copy) NSString *mileage;

/**
 *  油量
 */
@property (nonatomic, copy) NSString *petrol;

/**
 *  发动机性能（好、异常）
 */
@property (nonatomic, copy) NSString *isEngineGood;

/**
 *  变速器性能（好、异常）
 */
@property (nonatomic, copy) NSString *isTransmissionGood;

/**
 *  车灯好坏
 */
@property (nonatomic, copy) NSString *isLightGood;

+ (instancetype)carInfoWithDict:(NSDictionary *)dict;
@end
