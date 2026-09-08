#import "RNSSplitColumnController.h"

#import "RNSSplitColumnControllerDelegate.h"
#import "RNSSplitColumnFrameObserver.h"
#import "RNSSplitColumnFrameObserverDelegate.h"
#import "RNSStackCoordinator.h"

@interface RNSSplitColumnController () <RNSSplitColumnFrameObserverDelegate>
@end

@implementation RNSSplitColumnController {
  RNSStackCoordinator *_stackCoordinator;
  NSArray<UIView<RNSStackScreenProviding> *> *_screens;
  RNSSplitColumnFrameObserver *_frameObserver;
}

- (instancetype)init
{
  if (self = [super init]) {
    _stackCoordinator = [RNSStackCoordinator new];
    _screens = @[];
    // The view must exist to observe its frame; it is loaded before the Split installs it in a column anyway.
    [self.navigationController loadViewIfNeeded];
    _frameObserver = [[RNSSplitColumnFrameObserver alloc] initWithNavigationController:self.navigationController
                                                                              delegate:self];
    [_frameObserver registerForViewFrameChanges];
  }

  return self;
}

- (UINavigationController *)navigationController
{
  return _stackCoordinator.navigationController;
}

#pragma mark - Screens

- (void)setScreens:(NSArray<UIView<RNSStackScreenProviding> *> *)screens
{
  for (UIView<RNSStackScreenProviding> *screen in _screens) {
    if (![screens containsObject:screen]) {
      [_stackCoordinator removeScreen:screen];
    }
  }

  [screens enumerateObjectsUsingBlock:^(UIView<RNSStackScreenProviding> *screen, NSUInteger index, BOOL *stop) {
    if (![self->_screens containsObject:screen]) {
      [self->_stackCoordinator insertScreen:screen atIndex:index];
    }
  }];

  _screens = [screens copy];
}

- (void)screenDidChangeActivityMode:(UIView<RNSStackScreenProviding> *)screen
{
  [_stackCoordinator screenDidChangeActivityMode:screen];
}

- (void)flushPendingUpdates
{
  [_stackCoordinator flushPendingUpdates];
}

#pragma mark - RNSSplitColumnFrameObserverDelegate

- (void)frameObserver:(RNSSplitColumnFrameObserver *)observer
    didChangeFrameOriginOfNavigationController:(UINavigationController *)navigationController
{
  [self.delegate splitColumnControllerFrameOriginDidChange:self];
}

@end
