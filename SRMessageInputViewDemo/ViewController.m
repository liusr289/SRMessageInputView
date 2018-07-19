//
//  ViewController.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "ViewController.h"
#import "SRMessageInputView.h"

@interface ViewController ()

@property (weak, nonatomic) SRMessageInputView *messageInputView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    SRMessageInputView *messageInputView = [[SRMessageInputView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
    self.messageInputView = messageInputView;
    [self.view addSubview:messageInputView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 监听键盘回收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 监听bottomView frame变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageInputViewChangeFrame:) name:SRMessageInputViewChangeFrameNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SRMessageInputViewChangeFrameNotification object:nil];
    
}

// 处理messageInputView frame change
- (void)messageInputViewChangeFrame:(NSNotification *)noti {
//    CGRect bottomViewEndFrame = [noti.userInfo[SRMessageInputViewEndFrameKey] CGRectValue];

}


// 处理键盘弹出
- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat translationY = [UIScreen mainScreen].bounds.size.height - keyboardRect.origin.y;
    [UIView animateWithDuration:duration animations:^{
        self.messageInputView.transform = CGAffineTransformMakeTranslation(0, -translationY);
    }];
    
}

// 点击tableView隐藏键盘(仅在键盘弹出时有效)
- (void)tapToEndEdit:(UITapGestureRecognizer *)tapGes {
    [self.view endEditing:YES];
}

// 处理键盘隐藏
- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.messageInputView.transform = CGAffineTransformIdentity;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
