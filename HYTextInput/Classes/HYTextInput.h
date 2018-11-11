//
//  HYTextInput.h
//  HYFoundation
//
//  Created by ocean on 2018/8/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HYTextInput <NSObject>

#pragma mark - UITextPosition,UITextRange 和 NSRange 的转化
- (UITextPosition *)hy_beginningPositionFromRange:(NSRange)range;
- (UITextPosition *)hy_endPositionFromRange:(NSRange)range;
- (UITextRange *)hy_textRangeFromRange:(NSRange)range;
- (NSRange)hy_rangeFormTextRange:(UITextRange *)textRange;
- (NSInteger)hy_indexFromPositon:(UITextPosition *)position;

#pragma mark - select 选中
/// 是否有选中的内容
- (BOOL)hy_hasSelectedText;
/// 选中的内容
@property (nonatomic, copy, readonly) NSString *hy_selectedText;
/// 选中的范围
@property (nonatomic, assign, readonly) NSRange hy_selectedRange;

#pragma mark - marked 临时的
/// 是否有临时的，还未确定的内容
- (BOOL)hy_hasMarkedText;
/// 临时的，还未确定的内容
@property (nonatomic, copy, readonly) NSString *hy_markedText;
/// 还未确定的内容的范围
@property (nonatomic, assign, readonly) NSRange hy_markedRange;

#pragma mark - cursor 光标位置
/**
 1、光标位置实质上就是选中的文字范围`selectedTextRange`，只不过是长度为0
 2、光标位置从0开始，到length结束，即 [0, length]
 */

/// 获取/设置 当前的光标位置
@property (nonatomic, assign) NSUInteger hy_cursorPosition;
/// 移动光标位置到 index 位置处
- (void)hy_moveCursorTo:(NSUInteger)index;
/// 移动光标位置到 开始 位置处
- (void)hy_moveCursorToBeginPostion;
/// 移动光标位置到 末尾 位置处
- (void)hy_moveCursorToEndPostion;
/// 光标是否在 开始 位置处
@property (nonatomic, assign, readonly) BOOL hy_cursorIsAtBeginPostion;
/// 光标是否在 末尾 位置处
@property (nonatomic, assign, readonly) BOOL hy_cursorIsAtEndPostion;

#pragma mark - 限制输入
/// 最大输入长度
@property (nonatomic, assign) NSUInteger hy_maxInputLength;
/// 超过最大输入长度，是否进行截断处理，默认是YES
@property (nonatomic, assign) BOOL hy_truncatedWhenOverMaxInputLength;

@end
