//
//  VICarEwmScanController.h
//  VehicleInternet
//
//  Created by joker on 16/4/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnBlock)(NSString *result);


@interface VICarEwmScanController : UIViewController



@property (nonatomic,copy) ReturnBlock returnBlock;


- (void)returnBlock:(ReturnBlock)block;

@end
