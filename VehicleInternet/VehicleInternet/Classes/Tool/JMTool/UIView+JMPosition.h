//
//  UIView+JMPosition.h
//  JMSlowShow
//
//  Created by joker on 16/2/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JMPosition)

/** 长度和宽度 */
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
/** 顶部和底部 */
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;
/** 左面和右面 */
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
/** 原点 */
@property (nonatomic,assign) CGPoint origin;
/** 大小尺寸 */
@property (nonatomic,assign) CGSize size;
/** x y */
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
/** 中心位置 */
@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;







@end
