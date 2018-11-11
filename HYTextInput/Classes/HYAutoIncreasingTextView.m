//
//  HYAutoIncreasingTextView.m
//  HYFoundation
//
//  Created by ocean on 2018/8/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import "HYAutoIncreasingTextView.h"

@interface HYAutoIncreasingTextView ()
@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@end

@implementation HYAutoIncreasingTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollEnabled = NO;
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        _autoIncreasingDirection = HYAutoIncreasingTextViewDirectionBottom;
    }
    return self;
}

- (void)textValueDidChanged {
    [super textValueDidChanged];
    // 高度计算
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)].height);
    // 文字高度发生了改变
    if (self.textHeight != height) {
        // 当高度大于最大高度时，需要滚动
        self.scrollEnabled = height > self.maxHeight && self.maxHeight > 0;
        self.textHeight = height;
        // 更新布局，不能滚动的状态才要更新布局（不能根据高度判断）
        if (!self.scrollEnabled) {
            CGRect frame = self.frame;
            if (self.autoIncreasingDirection == HYAutoIncreasingTextViewDirectionBottom) {
                frame.size.height = self.textHeight;
            } else {
                frame.size.height = self.textHeight;
                frame.origin.y = CGRectGetMaxY(self.frame) - frame.size.height; // 这里是之前的最大Y值
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = frame;
            }];
        } else {
//            // 光标在最后位置处理，滚动到最后
//            if (self.hy_cursorIsAtEndPostion) {
//                CGRect lastRect = [[[self selectionRectsForRange:self.selectedTextRange] lastObject] CGRectValue];
//                [self scrollRectToVisible:lastRect animated:YES];
//                // 最后一个位置的字符可见
////                NSRange lastRange = NSMakeRange(self.text.length, 0);
////                [self scrollRangeToVisible:lastRange];
////                CGPoint contentOffset = self.contentOffset;
////                contentOffset.y += self.textContainerInset.bottom + self.font.lineHeight;
////                self.contentOffset = contentOffset;
//            }
        }
//        [self.superview layoutIfNeeded];
        // 通知代理
        if (self.hy_autoIncreasingDelegate && [self.hy_autoIncreasingDelegate respondsToSelector:@selector(hy_autoIncreasingTextViewHeightDidChanged:height:)]) {
            [self.hy_autoIncreasingDelegate hy_autoIncreasingTextViewHeightDidChanged:self height:height];
        }
    }
}

- (void)textDidBeginEditing {
    // 开始聚焦输入情况，调整高度，防止一开始高度设置和字体不一致的情况
    [self textValueDidChanged];
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines {
    _maxNumberOfLines = maxNumberOfLines;
    CGFloat maxHeight = self.font.lineHeight * _maxNumberOfLines + self.textContainerInset.top + self.textContainerInset.bottom;
    self.maxHeight = ceilf(maxHeight);
}

- (BOOL)isMaxHeightReached {
    return self.scrollEnabled;
}

@end
