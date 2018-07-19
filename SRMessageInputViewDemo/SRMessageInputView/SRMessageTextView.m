//
//  SRMessageTextView.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "SRMessageTextView.h"
#import "NSString+SRRect.h"

static CGFloat const kDefaultHeight = 36.0; // 输入框默认高度
static NSUInteger kMaxInputLine = 4;  // 输入框最大可显示行数

// 聊天输入框文字行高
#define kTextlineHeight  (NSUInteger)[UIFont systemFontOfSize:16].lineHeight

@interface SRMessageTextView ()

@property (nonatomic, assign) CGFloat textViewMaxH; // 聊天输入框最大高度
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;

@end

@implementation SRMessageTextView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:16];
        // 通过KVO机制调整偏移量
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        // 暂时将文本输入框最大高度定为4行文字的高度，+9是为了当输入文字的行数大于4时，滚动输入框可以完整显示第一行或最后一行文字
        _textViewMaxH = kTextlineHeight*kMaxInputLine + 9;
        // 添加一个滑动手势，当输入文字小于4行屏蔽滚动效果
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
        _panGes = panGes;
        [self addGestureRecognizer:panGes];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)panGes:(UIPanGestureRecognizer *)pan {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"contentOffset"]) {

        CGFloat textHeight = [self.text sr_stringSizeWithFont:[UIFont systemFontOfSize:16] maxWidth:self.bounds.size.width - 10 maxHeight:[UIScreen mainScreen].bounds.size.height].height;
        if (textHeight < kDefaultHeight) {
            return;     // 输入单行文字，不做处理
        }
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat contentOffsetY = offset.y;
        // 输入文字行数
        NSInteger lineNum = (NSInteger)(textHeight/kTextlineHeight);
        if (textHeight < _textViewMaxH) {
            if (contentOffsetY == 0 || contentOffsetY > 6) {
                [self setContentOffset:CGPointMake(0, 6)];
            }
            self.showsVerticalScrollIndicator = NO;
        } else if (textHeight > _textViewMaxH) {
            CGFloat offsetY = (lineNum - kMaxInputLine)*kTextlineHeight +8;
            if (!self.isDragging && !self.isDecelerating && contentOffsetY != offsetY) {
                self.contentOffset = CGPointMake(0, offsetY);
            }
            self.showsVerticalScrollIndicator = YES;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textHeight = [self.text sr_stringSizeWithFont:[UIFont systemFontOfSize:16] maxWidth:self.bounds.size.width - 10 maxHeight:[UIScreen mainScreen].bounds.size.height].height;
    if (textHeight < _textViewMaxH) {
        self.panGes.enabled = YES;
    } else {
        self.panGes.enabled = NO;
    }
}


@end
