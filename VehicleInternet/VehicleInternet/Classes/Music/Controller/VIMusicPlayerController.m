//
//  VIMusicPlayerController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/21.
//  Copyright © 2016年 TomorJM. All rights reserved.
//


#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height - 49
#import "VIMusicPlayerController.h"
#import "VIMusicModel.h"
#import "VIHomeMapController.h"
#import "VIMusicListController.h"

typedef enum : NSUInteger {
    MusicPLayModeRandomPlay,
    MusicPLayModeOneSongPlay,
    MusicPLayModeDefault,
} MusicPLayMode;


@interface VIMusicPlayerController () <AVAudioPlayerDelegate,VIMusicListDelegate>
{
    
    UIImageView *_backView;//背景视图
    UIView *_bottomView;//底部视图
    UIButton *startAndStopBtn;//播放、暂停
    UIButton *lastButton;//上一曲
    UIButton *nextButton;//下一曲的实现
    UIButton *musicPLayModeButton;
    UISlider *slider;//滑块 时间进度条
    UILabel *totalLable;//显示总时间的lable
    UILabel *startLable;//歌曲进度的lable
    NSInteger len;
}
@property (nonatomic, strong) NSArray *musicArr;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSNumber *musicTime;
@property (nonatomic, assign) BOOL hasChangedSong;
@property (nonatomic, assign) MusicPLayMode musicPlayMode;

@end

static int page = 0;
static int time2 = 0;

@implementation VIMusicPlayerController

#pragma mark - 懒加载
- (NSArray *)musicArr{
    if (!_musicArr) {
        NSArray *arr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"music" ofType:@"plist"]];
        
        NSMutableArray *muteArr = [NSMutableArray array];
        for (NSDictionary *dict in arr) {
            [muteArr addObject:[VIMusicModel musicWithDict:dict]];
        }
        _musicArr = muteArr;
    }
    return _musicArr;
}

- (void)didSelectedMusicForRowAtIndexPath:(NSIndexPath *)indexPath {
    page = (int)indexPath.row;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *time = [NSUserDefaults standardUserDefaults];
    self.musicTime = [time valueForKey:@"time"];
    
    //设置播放模式
    self.musicPlayMode = MusicPLayModeDefault;
    
    //调用BackView背景视图
    [self BackView];
   
    //调用BottomView 底部视图
    [self BottomView];
    
    self.currentPage = page;
    [self reloadData];

    
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.currentPage != page) {
        [self reloadData];
    }
    
}

//改变数值的方法 刷新数据
-(void)reloadData{
    startAndStopBtn.selected = !self.player.isPlaying;
    self.currentPage = page;
    
    
    VIMusicModel *musicModel = self.musicArr[page];
    NSString *imageStr = musicModel.image;
    NSString *totalStr = musicModel.total;
    //创建播放器
    NSString *path = [[NSBundle mainBundle] pathForResource:musicModel.url ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    //初始化AVAudioPlayer实例对象
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    //设置开始的音量
    self.player.volume = 1;
    
    //设置当前的时间
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *time = [NSUserDefaults standardUserDefaults];
        self.musicTime = [time valueForKey:@"time"];
        self.player.currentTime = [self.musicTime floatValue];
        [self.player play];
    });
    
    //设置代理
    self.player.delegate = self;
    

    if ([self.player prepareToPlay]) {
        [self.player play];
        startAndStopBtn.selected = self.player.isPlaying;
        self.hasChangedSong = self.player.isPlaying;
    }
    
    CADisplayLink *display = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
    
    //添加到NSRunLoop上
    [display addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    //给各个属性赋值
    _backView.image = [UIImage imageNamed:imageStr];
    slider.value = 0;
        
    totalLable.text = totalStr;
    startLable.text = [self floatToStr:slider.value];
    time2 = 0;

    
}


//播放完成是调用--------AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.musicPlayMode == MusicPLayModeRandomPlay) {
        int nextPage = arc4random()%4;
        while (page == nextPage) {
            nextPage = arc4random()%4;
        }
        page = nextPage;
        [self reloadData];
    } else if (self.musicPlayMode == MusicPLayModeOneSongPlay){
        [self reloadData];
    } else {
        [self nextButtonAct];
    }
}


-(void)display{
    
    //设置当前的时间label
    startLable.text = [NSString stringWithFormat:@"%02d:%02d",(int)_player.currentTime/60,(int)_player.currentTime%60];
    
    //设置总的时间label
    totalLable.text = [NSString stringWithFormat:@"%02d:%02d",(int)_player.duration/60,(int)_player.duration%60];
    
    //    //设置播放时间的推进
    slider.value = _player.currentTime/_player.duration;
}

//播放暂停startAndStopBtnAct的点击响应事件
-(void)startAndStopBtnAct{
    
    if (_player.playing) {
        
        //暂停播放
        [_player pause];
        
        startAndStopBtn.selected = self.player.isPlaying;
        
    }else{
        
        //继续播放
        [_player play];
        startAndStopBtn.selected = self.player.isPlaying;
    }
}

//上一曲lastButton的点击响应事件
-(void)lastButtonAct{
    if(page > 0){
        page--;
        [self reloadData];
    }else{
        
        page = 3;
        [self reloadData];
    }
}

//下一曲nextButton的点击响应事件
-(void)nextButtonAct{
    len = [_musicArr count];
    if (self.musicPlayMode == MusicPLayModeRandomPlay) {
        int nextPage = arc4random()%4;
        while (page == nextPage) {
            nextPage = arc4random()%4;
        }
        page = nextPage;
        [self reloadData];
    } else {
        if(page < len-1){
            page++;
            [self reloadData];
        }else{
            page = 0;
            [self reloadData];
        }
    }
}

//播放模式
- (void)musicPlayModeChange {
    if (self.musicPlayMode == MusicPLayModeDefault) {
        [musicPLayModeButton setBackgroundImage:[UIImage imageNamed:@"单曲循环.png"] forState:UIControlStateNormal];
        self.musicPlayMode = MusicPLayModeOneSongPlay;
    } else if (self.musicPlayMode == MusicPLayModeOneSongPlay) {
        [musicPLayModeButton setBackgroundImage:[UIImage imageNamed:@"随机.png"] forState:UIControlStateNormal];
        self.musicPlayMode = MusicPLayModeRandomPlay;
    } else if (self.musicPlayMode == MusicPLayModeRandomPlay) {
        [musicPLayModeButton setBackgroundImage:[UIImage imageNamed:@"循环.png"] forState:UIControlStateNormal];
        self.musicPlayMode = MusicPLayModeDefault;
    }
}

//浮点型 -->str
-(NSString*)floatToStr:(float)time{
    
    int minute = time/60;
    int second = (int)time%60;
    
    NSString *totalStr = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    
    return totalStr;
}


//时间播放条sliderAct的点击响应事件
-(void)sliderAct{
    
    //设置播放时间的推进
    _player.currentTime = slider.value * _player.duration;
}

#pragma mark  ************//创建底部视图//******************
-(void)BottomView{
    
#pragma mark UIView
    //创建一个UIView
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH-100, kScreenW, 100)];
    //设置bottomView的背景颜色
    _bottomView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
    //把bottomView给主窗口
    [self.view addSubview:_bottomView];
    
#pragma mark UIButton
    //创建一个播放与暂停的button
    startAndStopBtn = [[UIButton alloc]initWithFrame:CGRectMake((kScreenW-60)/2, (100-60)/2, 60, 60)];
    [startAndStopBtn setImage:[UIImage imageNamed:@"playing_btn_play_n@2x"] forState:UIControlStateNormal];
    [startAndStopBtn setImage:[UIImage imageNamed:@"playing_btn_play_h@2x"] forState:UIControlStateHighlighted];
    [startAndStopBtn setImage:[UIImage imageNamed:@"playing_btn_pause_n@2x"] forState:UIControlStateSelected];

    [_bottomView addSubview:startAndStopBtn];
    
    //添加点击响应事件
    [startAndStopBtn addTarget:self action:@selector(startAndStopBtnAct) forControlEvents:UIControlEventTouchUpInside];
    
    //创建上一曲的 button
    lastButton = [[UIButton alloc]initWithFrame:CGRectMake((kScreenW-60)/2-50-15, (100-50)/2, 50, 50)];
    [lastButton setImage:[UIImage imageNamed:@"playing_btn_pre_n@2x"] forState:UIControlStateNormal];
    [lastButton setImage:[UIImage imageNamed:@"playing_btn_pre_h@2x"] forState:UIControlStateHighlighted];
    
    [_bottomView addSubview:lastButton];

    //添加点击响应事件
    [lastButton addTarget:self action:@selector(lastButtonAct) forControlEvents:UIControlEventTouchUpInside];
    
    //创建下一曲的 button
    nextButton = [[UIButton alloc]initWithFrame:CGRectMake((kScreenW-60)/2+50+25, (100-50)/2, 50, 50)];
    [nextButton setImage:[UIImage imageNamed:@"playing_btn_next_n@2x"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"playing_btn_next_h@2x"] forState:UIControlStateHighlighted];
    [_bottomView addSubview:nextButton];

    //创建播放模式按钮
    musicPLayModeButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenW-60)/2+50+25+55, (100-50)/2, 40, 40)];
    [musicPLayModeButton setBackgroundImage:[UIImage imageNamed:@"循环.png"] forState:UIControlStateNormal];
    [musicPLayModeButton addTarget:self action:@selector(musicPlayModeChange) forControlEvents:UIControlEventTouchDown];
    [_bottomView addSubview:musicPLayModeButton];
    
    //添加点击响应时间
    [nextButton addTarget:self action:@selector(nextButtonAct) forControlEvents:UIControlEventTouchUpInside];
    
#pragma mark UISlider
    //创建一个时间进度条 UISlider
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, -5 ,kScreenW, 10)];
    //把slider给底部窗口
    [_bottomView addSubview:slider];
    
    UIImage *image = [[UIImage imageNamed:@"playing_slider_play_left@2x"]stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [slider setMinimumTrackImage:image forState:UIControlStateNormal];
    
    //给slider设置一个背景图片
    [slider setThumbImage:[UIImage imageNamed:@"com_thumb_max_n-Decoded"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(sliderAct) forControlEvents:UIControlEventValueChanged];
#pragma mark UILable
    //创建显示时间的lable
    totalLable = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW-50, 5, 50, 20)];
    //文本的显示颜色
    totalLable.textColor = [UIColor whiteColor];
    //把它给底部视图
    [_bottomView addSubview:totalLable];
    
    //创建显示时间的lable
    startLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 50, 20)];
    //文本的显示颜色
    startLable.textColor = [UIColor whiteColor];
    //把它给底部视图
    [_bottomView addSubview:startLable];
    
}

#pragma mark  ************//创建背景视图//******************
-(void)BackView{
    
    //创建背景View
    _backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //设置背景颜色
    _backView.backgroundColor = [UIColor whiteColor];
    //把背景视图给窗口
    [self.view addSubview:_backView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

