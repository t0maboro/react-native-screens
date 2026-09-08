#import "RNSSplitColumnController.h"

#import "RNSSplitColumnControllerDelegate.h"
#import "RNSSplitColumnFrameObserver.h"
#import "RNSSplitColumnFrameObserverDelegate.h"

@interface RNSSplitColumnController () <RNSSplitColumnFrameObserverDelegate>
@end

@implementation RNSSplitColumnController {
  RNSSplitColumnFrameObserver *_frameObserver;
}

- (instancetype)initWithScreenController:(UIViewController *)screenController
{
  if (self = [super init]) {
    _navigationController = [[UINavigationController alloc] initWithRootViewController:screenController];
    // The view must exist to observe its frame; it is loaded before the Split installs it in a column anyway.
    [_navigationController loadViewIfNeeded];
    _frameObserver = [[RNSSplitColumnFrameObserver alloc] initWithNavigationController:_navigationController
                                                                              delegate:self];
    [_frameObserver registerForViewFrameChanges];
  }

  return self;
}

- (void)setScreenController:(UIViewController *)screenController
{
  if (_navigationController.viewControllers.count == 1 &&
      _navigationController.viewControllers.firstObject == screenController) {
    return;
  }
  [_navigationController setViewControllers:@[ screenController ] animated:NO];
}

#pragma mark - RNSSplitColumnFrameObserverDelegate

- (void)frameObserver:(RNSSplitColumnFrameObserver *)observer
    didChangeFrameOriginOfNavigationController:(UINavigationController *)navigationController
{
  [self.delegate splitColumnControllerFrameOriginDidChange:self];
}

@end
