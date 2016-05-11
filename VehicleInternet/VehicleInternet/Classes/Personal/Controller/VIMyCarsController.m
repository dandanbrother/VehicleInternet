//
//  VIMyCarsController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarsController.h"
#import "VICarInfoModel.h"
#import "VIMyCarCell.h"
#import "VIModifyCarController.h"
#import "VICarEwmController.h"
#import "VICheckIllegalInformation.h"

@interface VIMyCarsController () <VIMyCarCellDelegate>
@property (nonatomic, strong) NSMutableArray *carList;
@property (nonatomic, assign) NSInteger sectionNum;
@end

@implementation VIMyCarsController

#pragma mark - 懒加载
- (NSMutableArray *)carList{
    if (!_carList) {
        _carList = [NSMutableArray array];
    }
    return _carList;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[VIModifyCarController class]]) {
        VIModifyCarController *vc = segue.destinationViewController;
        
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        
        vc.car = self.carList[selectedIndex.row/2];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count !=0 && objects !=nil &&objects.count != self.carList.count)
        {
            [self.carList removeAllObjects];
            for (VICarInfoModel *model in objects) {
                [self.carList addObject:model];
            }
            [self.tableView reloadData];
        }
        
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //覆盖多余空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.showsVerticalScrollIndicator = NO;
    //取消cell分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.carList.count * 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row % 2 != 0) {
        
        VIMyCarCell *cell = [VIMyCarCell carInfoCellWithTableView:tableView];
        cell.carInfo = self.carList[indexPath.row/2];
        cell.delegate = self;
        return cell;
    } else {
        static NSString *CELL_ID2 = @"SOME_STUPID_ID2";

        UITableViewCell * cell2 = [tableView dequeueReusableCellWithIdentifier:CELL_ID2];
        
        if (cell2 == nil)
        {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID2];
            [cell2 setUserInteractionEnabled:NO]; // prevent selection and other stuff
        }
        return cell2;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier  isEqual: @"SOME_STUPID_ID2"]) {
        cell.alpha = 0;
    } else {
        
        UIImageView *backGround = [[UIImageView alloc] initWithFrame:CGRectMake(cell.x, cell.y, cell.width, cell.height)];
        backGround.image = [UIImage imageNamed:@"CarCell.png"];
        cell.backgroundView = backGround;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        
        return 12;
    } else {
        return 150;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexPath *blank = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:0];
        [self.carList[indexPath.row/2] deleteInBackground];
        [self.carList removeObjectAtIndex:indexPath.row/2];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,blank, nil] withRowAnimation:UITableViewRowAnimationLeft];
       
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"modify" sender:self];

}



#pragma mark - VIMyCarCellDelegate
- (void)clickToShowEwm:(UIButton *)btn carInfo:(VICarInfoModel *)carInfo
{
    VICarEwmController *ewmVC = [VICarEwmController ewmShownWithCarInfo:carInfo];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ewmVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)clickToShowIllegalInfo:(UIButton *)btn carInfo:(VICarInfoModel *)carInfo {
    VICheckIllegalInformation *infoVC = [[VICheckIllegalInformation alloc] init];
    infoVC.model = carInfo;
    [self.navigationController pushViewController:infoVC animated:YES];
}

@end
