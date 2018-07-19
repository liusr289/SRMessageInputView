//
//  SRMessageInputView.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "SRMessageInputView.h"
#import "SRMessageTextView.h"
#import "SRVoiceHud.h"
#import "UIColor+SRHex.h"
#import "UIImage+SRColor.h"
#import "NSString+SRRect.h"

NSString * const SRMessageInputViewChangeFrameNotification = @"SRMessageInputViewChangeFrameNotification";
NSString * const SRMessageInputViewEndFrameKey = @"SRMessageInputViewEndFrameKey";

#define kInputTextViewHeight 36
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface SRMessageInputView () <UITextViewDelegate>

@property (nonatomic, strong) UIButton *changeInputModeBtn; // 切换文字、语音输入
@property (nonatomic, strong) SRMessageTextView *textView;
@property (nonatomic, strong) UIButton *holdOnBtn;

@end

@implementation SRMessageInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupSubviews];
    return self;
}

- (void)setupSubviews {
    self.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
    self.changeInputModeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.changeInputModeBtn.frame = CGRectMake(5, 11, 28, 28);
    [self.changeInputModeBtn setImage:[[UIImage imageNamed:@"icon_message_input_voice"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.changeInputModeBtn setImage:[[UIImage imageNamed:@"icon_message_input_text"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.changeInputModeBtn addTarget:self action:@selector(changeInputModeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeInputModeBtn setTintColor:[UIColor clearColor]];
    [self addSubview:self.changeInputModeBtn];
    
    
    CGRect textViewRect = CGRectMake(CGRectGetMaxX(self.changeInputModeBtn.frame) + 5, 7, [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(self.changeInputModeBtn.frame) - 5 - 15, 36);
    self.textView = [[SRMessageTextView alloc] initWithFrame:textViewRect];
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor colorWithHex:0xd8d9dc].CGColor;
    self.textView.clipsToBounds = YES;
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeySend;
    [self addSubview:self.textView];
    
    self.holdOnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.holdOnBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.holdOnBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    self.holdOnBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.holdOnBtn setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateNormal];
    self.holdOnBtn.frame = self.textView.frame;
    [self.holdOnBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xf5f5f5]] forState:UIControlStateNormal];
    [self.holdOnBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xc6c7ca]] forState:UIControlStateHighlighted];
    self.holdOnBtn.layer.cornerRadius = 5.0;
    self.holdOnBtn.clipsToBounds = YES;
    self.holdOnBtn.layer.borderWidth = 0.5;
    self.holdOnBtn.layer.borderColor = [UIColor colorWithHex:0xd8d9dc].CGColor;
    [self.holdOnBtn addTarget:self action:@selector(holdOnBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.holdOnBtn addTarget:self action:@selector(holdOnBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [self.holdOnBtn addTarget:self action:@selector(holdOnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.holdOnBtn addTarget:self action:@selector(holdOnBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [self.holdOnBtn addTarget:self action:@selector(holdOnBtnTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    [self addSubview:self.holdOnBtn];
    self.holdOnBtn.hidden = YES;
}

#pragma mark - 切换文字/语音输入
- (void)changeInputModeAction:(UIButton *)button {
    button.selected = !button.selected;
    if (button.isSelected) {
        [self.textView resignFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
    [self changeFrameIsVoiceInputMode:button.isSelected];
    self.holdOnBtn.hidden = !button.isSelected;
}

- (void)holdOnBtnTouchDown:(UIButton *)button {
    [SRVoiceHud show];
}

- (void)holdOnBtnDragOutside:(UIButton *)button {
    [button setTitle:@"松开 取消" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xc6c7ca]] forState:UIControlStateNormal];
    [SRVoiceHud changeHudState:SRVoiceHudStateCancel];
}

- (void)holdOnTouchUpInside:(UIButton *)button {
    NSLog(@"%@",button.titleLabel.text);
    [button setTitle:@"按住 说话" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xf5f5f5]] forState:UIControlStateNormal];
    [SRVoiceHud hide];
    
    if ([[SRVoiceHud hud] state] == SRVoiceHudStateLackTime) {
        return;
    }

}

- (void)holdOnBtnTouchUpOutside:(UIButton *)button {
    [button setTitle:@"按住 说话" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xf5f5f5]] forState:UIControlStateNormal];
    [SRVoiceHud hide];
}

- (void)holdOnBtnDragInside:(UIButton *)button {
    [SRVoiceHud changeHudState:SRVoiceHudStateNormal];
}


#pragma mark - UITextViewDelagete
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat textViewNewHeight = [self caculateFrameHeight:textView.text].size.height - 14;
    if (textViewNewHeight != textView.bounds.size.height) {
        [self changeFrameIsVoiceInputMode:NO];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self changeFrameIsVoiceInputMode:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        textView.text = nil;
        return NO;
    }
    return YES;
}

#pragma mark - 改变bottomView的frame
- (void)changeFrameIsVoiceInputMode:(BOOL)voiceInputMode {
    if (voiceInputMode) {
        self.frame = CGRectMake(0, kSCREEN_HEIGHT - 50, kSCREEN_WIDTH, 50);
    } else {
        self.frame = [self caculateFrameHeight:_textView.text];
    }
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = self.bounds.size.height - 14;
    self.textView.frame = textViewFrame;
    CGRect aRect = self.changeInputModeBtn.frame;
    aRect.origin.y = self.bounds.size.height - 11 - 28;
    self.changeInputModeBtn.frame = aRect;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (CGRect)caculateFrameHeight:(NSString *)text {
    //输入框高度限制为4行文字高度
    NSInteger inputViewMaxH = (NSInteger)[UIFont systemFontOfSize:16].lineHeight*4+9;
    // 为了计算高度更精确,将计算文字的宽度-10
    CGFloat inputViewH = [text sr_stringSizeWithFont:[UIFont systemFontOfSize:16] maxWidth:kSCREEN_WIDTH - 28 - 10 - 15 - 10 maxHeight:kSCREEN_HEIGHT].height + 9;
    if (inputViewH > inputViewMaxH) {
        inputViewH = inputViewMaxH;
    }
    //输入框的初始高度为36
    if (inputViewH < kInputTextViewHeight) {
        inputViewH = kInputTextViewHeight;
    }
    CGRect frame = self.frame;
    CGFloat newHeight = inputViewH + 14;
    if (newHeight != frame.size.height) {
        CGFloat y = frame.origin.y - (newHeight - frame.size.height);
        frame.origin.y = y;
        frame.size.height = newHeight;
    }
    return frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[NSNotificationCenter defaultCenter] postNotificationName:SRMessageInputViewChangeFrameNotification object:nil userInfo:@{SRMessageInputViewEndFrameKey:[NSValue valueWithCGRect:self.frame]}];
}

@end
