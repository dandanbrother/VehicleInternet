//
//  VIMusicListController.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/21.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VIMusicListDelegate <NSObject>
@optional
- (void)didSelectedMusicForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface VIMusicListController : UITableViewController
@property (nonatomic, weak) id<VIMusicListDelegate> delegate;
@end
