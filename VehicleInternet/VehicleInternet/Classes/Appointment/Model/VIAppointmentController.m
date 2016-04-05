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
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        VIAppointmentComposeController *composeVC = (VIAppointmentComposeController*)[storyboard instantiateViewControllerWithIdentifier:@"VIAppointmentComposeController"];
        [self.navigationController pushViewController:composeVC animated:YES];
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
    

    
    VIUserModel *user = [VIUserModel currentUser];
    if (user == nil) {
        [self.appointments removeAllObjects];
        [self.myTableView reloadData];
        return;
    }
    AVQuery *query = [AVQuery queryWithClassName:@"VIAppointmentModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.appointments removeAllObjects];
        
        if (objects.count !=0 && objects !=nil) {
            for (VIAppointmentModel *appointment in objects) {
                [self.appointments addObject:appointment];
            }
            [self.myTableView reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    return 185;
}

#pragma mark - AppointmentCellDelegate
- (void)clickToShowEwm:(UIButton *)btn appointment:(VIAppointmentModel *)appointment
{

    VIEwmController *ewmVC = [VIEwmController ewmShownWithAppointment:appointment];
    [self.navigationController pushViewController:ewmVC animated:YES];
}

@end
