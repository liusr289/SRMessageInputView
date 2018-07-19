//
//  SRVoiceHud.h
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/18.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SRVoiceHudState) {
    SRVoiceHudStateNormal = 0,
    SRVoiceHudStateCancel,
    SRVoiceHudStateLackTime,
    SRVoiceHudStateOverTime,
};

@interface SRVoiceHud : UIView

@property (nonatomic, assign) SRVoiceHudState state;

+ (void)show;

+ (void)hide;

+ (void)changeHudState:(SRVoiceHudState)state;

+ (SRVoiceHud *)hud;

@end
