//
//  NSString+SRRect.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "NSString+SRRect.h"

@implementation NSString (SRRect)

- (CGSize)sr_stringSizeWithFont:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    return [self boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

@end
