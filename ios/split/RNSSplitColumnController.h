#pragma once

#import <UIKit/UIKit.h>
#import "RNSStackScreenProviding.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RNSSplitColumnControllerDelegate;

/**
 * @class RNSSplitColumnController
 * @brief Native owner of a Split column: the navigation controller installed in the UISplitViewController column,
 * the stack of screens shown in it and the observation of its frame.
 *
 * It has no React counterpart. The host creates one controller per column, installs its `navigationController` and
 * hands the column its screens in React order.
 */
@interface RNSSplitColumnController : NSObject

@property (nonatomic, weak, nullable) id<RNSSplitColumnControllerDelegate> delegate;

@property (nonatomic, strong, readonly, nonnull) UINavigationController *navigationController;

/**
 * @brief Replaces the screens of the column. Screens no longer present are popped and new ones pushed on the next
 * `flushPendingUpdates`.
 */
- (void)setScreens:(NSArray<UIView<RNSStackScreenProviding> *> *)screens;

- (void)screenDidChangeActivityMode:(UIView<RNSStackScreenProviding> *)screen;

/**
 * @brief Applies the pending push and pop operations to the navigation controller.
 */
- (void)flushPendingUpdates;

@end

NS_ASSUME_NONNULL_END
