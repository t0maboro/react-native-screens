#pragma once

#import "RNSStackNavigationController.h"
#import "RNSStackScreenProviding.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Native owner of a stack.
 *
 * Keeps the screens in React order, translates their mount, unmount and activity mode changes into push and pop
 * operations and applies them to the navigation controller in batches.
 */
@interface RNSStackCoordinator : NSObject

@property (nonatomic, strong, readonly, nonnull) RNSStackNavigationController *navigationController;

- (void)insertScreen:(nonnull UIView<RNSStackScreenProviding> *)screen atIndex:(NSInteger)index;

- (void)removeScreen:(nonnull UIView<RNSStackScreenProviding> *)screen;

- (void)screenDidChangeActivityMode:(nonnull UIView<RNSStackScreenProviding> *)screen;

/**
 * @brief Applies the pending push and pop operations, if any, to the navigation controller.
 */
- (void)flushPendingUpdates;

@end

NS_ASSUME_NONNULL_END
