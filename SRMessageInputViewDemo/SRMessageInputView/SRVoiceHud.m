//
//  SRVoiceHud.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/18.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "SRVoiceHud.h"
#import "UIColor+SRHex.h"

static SRVoiceHud *hud;
static NSTimer *recordTimer;
static NSTimeInterval recordDuration; // 当前录音时长
static NSTimeInterval maxRecordTime = 60; // 最长录音时间（秒）

@interface SRVoiceHud ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UIButton *button; // 屏蔽其他事件

@end

@implementation SRVoiceHud

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    self.textLabel = [UILabel new];
    self.textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textLabel];
    CGRect detailTextLabelRect = CGRectMake(5, self.bounds.size.height - 10 - 25, self.bounds.size.width - 10, 25);
    self.detailTextLabel = [[UILabel alloc] initWithFrame:detailTextLabelRect];
    self.detailTextLabel.layer.cornerRadius = 2;
    self.detailTextLabel.clipsToBounds = YES;
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.detailTextLabel];
    CGRect iconRect = CGRectMake((150 - 58)/2 - 10, (125 - 70)/2, 58, 70);
    self.iconImgView = [[UIImageView alloc] initWithFrame:iconRect];
    [self.iconImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.iconImgView];
    
}

+ (void)validRecordTimer {
    recordTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(recordDuration) userInfo:nil repeats:YES];
    recordDuration = 0;
    [[NSRunLoop currentRunLoop] addTimer:recordTimer forMode:NSRunLoopCommonModes];
    [recordTimer setFireDate:[[NSDate date] dateByAddingTimeInterval:1]];
}

+ (void)invalidRecordTimer {
    [recordTimer invalidate];
    recordTimer = nil;
}

+ (void)recordDuration {
    if (recordDuration < maxRecordTime) {
        recordDuration += 1;
    }
    if ((recordDuration > 49 && recordDuration < maxRecordTime) && hud.state == SRVoiceHudStateNormal) {
        [self changeHudState:SRVoiceHudStateNormal];
    }
    if (recordDuration == maxRecordTime) {
        [self changeHudState:SRVoiceHudStateOverTime];
    }
}


+ (void)show {
    if (hud == nil) {
        CGRect aRect = CGRectMake(([UIScreen mainScreen].bounds.size.width - 150)/2, ([UIScreen mainScreen].bounds.size.height - 40 - 150)/2, 150, 150);
        hud = [[SRVoiceHud alloc] initWithFrame:aRect];
    }
    hud.userInteractionEnabled = NO;
    UIWindow *currentWindow;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            currentWindow = window;
            break;
        }
    }
    if (hud.superview == nil) {
        [currentWindow addSubview:hud];
    }
    [self changeHudState:SRVoiceHudStateNormal];
    if (hud.button == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = currentWindow.bounds;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        hud.button = button;
    }
    [currentWindow addSubview:hud.button];
    [currentWindow bringSubviewToFront:hud.button];
    
    [self validRecordTimer];
}

+ (void)buttonClick:(UIButton *)button {
    
}

+ (void)changeHudState:(SRVoiceHudState)state {
    hud.state = state;
    UILabel *textLabel = hud.textLabel;
    UILabel *detailTextLabel = hud.detailTextLabel;
    UIImageView *iconImgView = hud.iconImgView;
    CGRect iconRect = iconImgView.frame;
    iconRect.origin.x = (150 - 58)/2;
    iconImgView.frame = iconRect;
    detailTextLabel.backgroundColor = [UIColor clearColor];
    switch (state) {
        case SRVoiceHudStateNormal:
        {
            if (recordDuration < maxRecordTime - 10) {
                textLabel.frame = CGRectZero;
                iconImgView.hidden = NO;
                detailTextLabel.text = @"手指上滑，取消发送";
                [iconImgView setImage:[UIImage imageNamed:@"icon_voice_toast_microphone"]];
                CGRect iconRect = iconImgView.frame;
                iconRect.origin.x = (150 - 58)/2 - 10;
                iconImgView.frame = iconRect;
            } else if (recordDuration < maxRecordTime) {
                iconImgView.hidden = YES;
                textLabel.frame = CGRectMake(0, 25, 150, 80);
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.font = [UIFont systemFontOfSize:80];
                textLabel.textColor = [UIColor whiteColor];
                textLabel.text = [NSString stringWithFormat:@"%.0f",maxRecordTime - recordDuration];
                detailTextLabel.text = @"手指上滑，取消发送";
            }
        }
            break;
        case SRVoiceHudStateCancel:
        {
            textLabel.frame = CGRectZero;
            iconImgView.hidden = NO;
            detailTextLabel.backgroundColor = [UIColor colorWithHex:0x9b3535];
            detailTextLabel.text = @"松开手指，取消发送";
            [iconImgView setImage:[UIImage imageNamed:@"icon_voice_toast_cancel"]];
        }
            break;
        case SRVoiceHudStateLackTime:
        {
            textLabel.frame = CGRectZero;
            iconImgView.hidden = NO;
            detailTextLabel.text = @"说话时间太短";
            [iconImgView setImage:[UIImage imageNamed:@"icon_voice_toast_exclamation"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self remove];
            });
        }
            break;
        case SRVoiceHudStateOverTime:
        {
            [self invalidRecordTimer];
            textLabel.frame = CGRectZero;
            iconImgView.hidden = NO;
            detailTextLabel.text = @"说话时间超长";
            [iconImgView setImage:[UIImage imageNamed:@"icon_voice_toast_exclamation"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                recordDuration = 0;
                [hud.button removeFromSuperview];
                [hud removeFromSuperview];
            });
        }
            break;
        default:
            break;
    }
}

+ (void)hide {
    if (recordDuration < 1) {
        [self changeHudState:SRVoiceHudStateLackTime];
    } else {
        [self changeHudState:SRVoiceHudStateNormal];
        [self remove];
    }
}

+ (void)remove {
    [self invalidRecordTimer];
    recordDuration = 0;
    [hud.button removeFromSuperview];
    [hud removeFromSuperview];
}

+ (SRVoiceHud *)hud {
    return hud;
}

@end
