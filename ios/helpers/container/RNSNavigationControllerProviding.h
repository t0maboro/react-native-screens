#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A component view backed by a navigation controller (e.g. `Stack.Host`), which a parent component
 * may install directly in its own view controller hierarchy instead of adding the component view
 * as a subview.
 */
@protocol RNSNavigationControllerProviding <NSObject>

@property (nonatomic, strong, readonly, nonnull) UINavigationController *navigationController;

/**
 * Set by the parent that installs `navigationController` itself; while YES the component must not
 * place the controller on its own.
 */
@property (nonatomic, getter=isNavigationControllerPlacedByParent) BOOL navigationControllerPlacedByParent;

/**
 * Applies pending updates of `navigationController` immediately instead of at the end of the
 * current mounting transaction. Called by the parent before it installs the controller.
 */
- (void)flushPendingUpdates;

@end

NS_ASSUME_NONNULL_END
