//
//  VIMusicModel.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/21.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIMusicModel : NSObject

@property (nonatomic,copy) NSString *singer;
@property (nonatomic,copy) NSString *song;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *total;
@property (nonatomic,copy) NSString *image;

+ (instancetype)musicWithDict:(NSDictionary *)dict;
@end
