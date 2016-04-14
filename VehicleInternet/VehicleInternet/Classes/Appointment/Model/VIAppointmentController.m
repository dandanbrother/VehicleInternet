//
//  VIAppointmentController.m
//  VehicleInternet
//
//  Created by joker on 16/3/25.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAppointmentController.h"
#import "VIAppointmentCell.h"
#import "VIEwmController.h"
#import "VIAppointmentModel.h"
#import <AVOSCloud/AVOSCloud.h>
#import "VIUserModel.h"
#import "JMLogInController.h"
#import "VIAppointmentComposeController.h"
#import "LCCoolHUD.h"
#import "VICarInfoModel.h"
@interface VIAppointmentController ()<UITableViewDataSource,AppointmentCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)creatNewAppointmentBtnClicked:(id)sender;

@property (nonatomic,strong) NSMutableArray *appointments;


@end


@implementation VIAppointmentController

- (IBAction)creatNewAppointmentBtnClicked:(id)sender {
    VIUserModel *user = [VIUserModel currentUser];
    NSLog(@"当前用户---%@",user.username);
    if (user == nil)
    {
        JMLogInController *logVC = [[JMLogInController alloc] init];
        logVC.title = @"登录";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else
    {
        //查询是否有绑定车辆
        AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
        [query whereKey:@"ownerID" equalTo:user.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count == 0) {
                [LCCoolHUD showFailure:@"请先绑定车辆!" zoom:YES shadow:YES];
            }else
            {
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                
                VIAppointmentComposeController *composeVC = (VIAppointmentComposeController*)[storyboard instantiateViewControllerWithIdentifier:@"VIAppointmentComposeController"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeVC];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
            }

        }];

        

        
    }
}

- (NSMutableArray *)appointments
{
    if (_appointments == nil) {
        _appointments = [NSMutableArray array];
    }
    return _appointments;
}

- (void)viewWillAppear:(BOOL)animated
{
    
   [LCCoolHUD showLoading:@"加载数据中" inView:self.view];
    
    VIUserModel *user = [VIUserModel currentUser];
    if (user == nil) {
        [self.appointments removeAllObjects];
        [self.myTableView reloadData];
        return;
    }
    AVQuery *query = [AVQuery queryWithClassName:@"VIAppointmentModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        // 服务器有新数据
        if (objects.count !=0 && objects !=nil &&objects.count != self.appointments.count)
        {
            
            [self.appointments removeAllObjects];
            [LCCoolHUD hideInView:self.view];
            for (VIAppointmentModel *appointment in objects) {
                [self.appointments addObject:appointment];
            }
            [self.myTableView reloadData];
        }else //没有数据
        {
            [LCCoolHUD hideInView:self.view];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //覆盖多余空白cell
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.myTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VIAppointmentCell *cell = [VIAppointmentCell appointmentCellWithTableView:tableView];
    cell.delegate = self;
    VIAppointmentModel *appointment = self.appointments[indexPath.row];
    cell.appointmentInfo = appointment;

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}

#pragma mark - AppointmentCellDelegate
- (void)clickToShowEwm:(UIButton *)btn appointment:(VIAppointmentModel *)appointment
{

    VIEwmController *ewmVC = [VIEwmController ewmShownWithAppointment:appointment];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ewmVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"删除");
        VIAppointmentModel *appointment = self.appointments[indexPath.row];
        [appointment deleteInBackground];
        [self.appointments removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
@end
