//
//  HYTextField.h
//  HYFoundation
//
//  Created by ocean on 2018/8/8.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYTextInput.h"

NS_ASSUME_NONNULL_BEGIN

@class HYTextField;

@protocol HYTextFieldDelegate <NSObject>

@optional
/// 输入内容发生改变的回调，用于自定义处理，比如限制长度，限制输入字符等，方法返回处理后的字符串内容即可
- (NSString *)hy_textFieldDidChangeHandler:(HYTextField *)textField;
/// 输入内容发生改变的代理方法
- (void)hy_textFieldDidChange:(HYTextField *)textField;

/// 超过最大长度限制的代理方法
- (void)hy_textFieldDidOverMaxInputLength:(HYTextField *)textField maxInputLength:(NSUInteger)maxInputLength;

@end

@interface HYTextField : UITextField <HYTextInput>

@property (nonatomic, weak, nullable) id<HYTextFieldDelegate> hy_delegate;

@end

NS_ASSUME_NONNULL_END
