//
//  UIColor+SRHex.m
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import "UIColor+SRHex.h"

@implementation UIColor (SRHex)

+ (UIColor *)colorWithHex:(long long)hexValue {
    CGFloat red = ((hexValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((hexValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (hexValue & 0x0000FF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
