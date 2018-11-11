//
//  HYAutoIncreasingTextView.h
//  HYFoundation
//
//  Created by ocean on 2018/8/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import "HYTextView.h"

NS_ASSUME_NONNULL_BEGIN

@class HYAutoIncreasingTextView;

/// 自动增长的方向
typedef NS_ENUM(NSUInteger, HYAutoIncreasingTextViewDirection) {
    /** 往下增长 */
    HYAutoIncreasingTextViewDirectionBottom,
    /** 往上增长 */
    HYAutoIncreasingTextViewDirectionTop
};


@protocol HYAutoIncreasingTextViewDelegate <HYTextViewDelegate>

@optional
/**
 高度发生变化的代理方法

 @param textView HYAutoIncreasingTextView
 @param height 变化后的高度
 */
- (void)hy_autoIncreasingTextViewHeightDidChanged:(HYAutoIncreasingTextView *)textView height:(CGFloat)height;

@end

@interface HYAutoIncreasingTextView : HYTextView

@property (nonatomic, weak, nullable) id<HYAutoIncreasingTextViewDelegate> hy_autoIncreasingDelegate;

/**
 最大的行数，影响最大高度
 */
@property (nonatomic, assign) NSUInteger maxNumberOfLines;

/**
 是否达到了最大高度
 NO：还没有达到最大高度，处于自增长状态，不可以滚动；
 YES：达到最大高度，可以滚动了；
 */
@property (nonatomic, assign, readonly, getter=isMaxHeightReached) BOOL maxHeightReached;

/**
 增长的方向，默认 HYAutoIncreasingTextViewDirectionBottom
 */
@property (nonatomic, assign) HYAutoIncreasingTextViewDirection autoIncreasingDirection;

@end

NS_ASSUME_NONNULL_END
