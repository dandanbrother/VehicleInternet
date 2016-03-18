//
//  HomeNavBarCityItem.m
//  SecondHand
//
//  Created by joker on 15/7/13.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import "HomeNavBarCityItem.h"
@interface HomeNavBarCityItem()

@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end

@implementation HomeNavBarCityItem

- (void)setTitle:(NSString *)title
{
    self.cityLabel.text = title;
}

+ (instancetype)homeNavBarCityItem
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeNavBarCityItem" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib  //不随屏幕拉伸
{
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.cityBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
