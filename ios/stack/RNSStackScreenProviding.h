#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNSStackHeaderConfigComponentView;
@class RNSStackScreenHeaderCoordinator;

typedef NS_ENUM(int, RNSStackScreenActivityMode) {
  RNSStackScreenActivityModeDetached = 0,
  RNSStackScreenActivityModeAttached = 1,
};

/**
 * @brief A React view backing a screen of a stack.
 *
 * The stack machinery (stack coordinator, navigation controller) reaches its screens only through this protocol,
 * so any component view whose controller can be pushed onto the stack's navigation controller may be its item.
 */
@protocol RNSStackScreenProviding <NSObject>

/** @brief View controller pushed onto the stack's navigation controller. */
- (nonnull UIViewController *)controller;

/** @brief Whether the screen is expected to be on the stack. */
- (RNSStackScreenActivityMode)activityMode;

- (nullable NSString *)screenKey;

/**
 * @brief Set once the screen left the stack natively (e.g. back gesture), so that its React unmount does not pop it
 * again.
 */
- (BOOL)isNativelyDismissed;
- (void)setIsNativelyDismissed:(BOOL)isNativelyDismissed;

- (nullable RNSStackHeaderConfigComponentView *)headerConfig;

/** @brief Coordinator applying the header config of this screen to its navigation item. */
- (nullable RNSStackScreenHeaderCoordinator *)headerCoordinator;

@end

NS_ASSUME_NONNULL_END
