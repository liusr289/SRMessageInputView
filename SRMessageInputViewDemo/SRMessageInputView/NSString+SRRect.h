//
//  NSString+SRRect.h
//  SRMessageInputViewDemo
//
//  Created by liusr on 2018/7/17.
//  Copyright © 2018年 liusr945. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (SRRect)

- (CGSize)sr_stringSizeWithFont:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height;

@end
