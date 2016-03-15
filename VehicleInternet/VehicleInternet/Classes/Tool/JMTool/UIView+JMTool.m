//
//  UIView+JMTool.m
//  JMSlowShow
//
//  Created by joker on 16/2/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "UIView+JMTool.h"

@implementation UIView (JMTool)

/**
 * 根据一个view返回它的快照
 */
- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    CGFloat reductionFactor = 1;
    UIGraphicsBeginImageContext(CGSizeMake(view.bounds.size.width/reductionFactor, view.bounds.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.bounds.size.width/reductionFactor, view.bounds.size.height/reductionFactor) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
