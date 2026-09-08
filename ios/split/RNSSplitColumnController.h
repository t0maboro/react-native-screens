#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNSSplitColumnControllerDelegate;

/**
 * @class RNSSplitColumnController
 * @brief Native owner of a Split column: the navigation controller installed in the UISplitViewController column and
 * the observation of its frame.
 *
 * It has no React counterpart. The host creates one controller per column, installs its `navigationController` and
 * hands the column its screen controller.
 */
@interface RNSSplitColumnController : NSObject

@property (nonatomic, weak, nullable) id<RNSSplitColumnControllerDelegate> delegate;

@property (nonatomic, strong, readonly, nonnull) UINavigationController *navigationController;

- (instancetype)initWithScreenController:(UIViewController *)screenController;

/**
 * @brief Makes the given controller the root of the column's navigation stack. No-op when it already is.
 */
- (void)setScreenController:(UIViewController *)screenController;

@end

NS_ASSUME_NONNULL_END
