//
//  HomeNavBarCityItem.h
//  SecondHand
//
//  Created by joker on 15/7/13.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeNavBarCityItem : UIView
+ (instancetype)homeNavBarCityItem;


- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic,copy) NSString *title;

- (void)setTitle:(NSString *)title;

@end
