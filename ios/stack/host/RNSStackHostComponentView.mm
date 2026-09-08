#import "RNSStackHostComponentView.h"

#import <React/RCTConversions.h>
#import <React/RCTMountingTransactionObserving.h>
#import <React/UIView+React.h>
#import <react/renderer/components/rnscreens/ComponentDescriptors.h>
#import <react/renderer/components/rnscreens/EventEmitters.h>
#import <react/renderer/components/rnscreens/Props.h>
#import <react/renderer/components/rnscreens/RCTComponentViewHelpers.h>
#import "RNSDefines.h"
#import "RNSLog.h"

#import "RNSContainerHelpers.h"
#import "RNSStackHeaderConfigComponentView.h"
#import "RNSStackNavigationController.h"
#import "RNSStackCoordinator.h"
#import "RNSStackScreenComponentView.h"

namespace react = facebook::react;

@interface RNSStackHostComponentView () <RCTMountingTransactionObserving>
@end

@implementation RNSStackHostComponentView {
  RNSStackCoordinator *_Nonnull _stackCoordinator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self initState];
  }
  return self;
}

- (void)initState
{
  static const auto defaultProps = std::make_shared<const react::RNSStackHostProps>();
  _props = defaultProps;

  _stackCoordinator = [RNSStackCoordinator new];
}

#pragma mark - UIKit Callbacks

- (void)didMoveToWindow
{
  RNSLog(@"[RNScreens] StackHost [%ld] attached to window", self.tag);
  RNSStackNavigationController *navigationController = _stackCoordinator.navigationController;
  if (self.window != nil && navigationController.parentViewController == nil) {
    BOOL mountResult = [RNSContainerHelpers addChildViewController:navigationController
                                          toViewControllerManaging:self.reactSuperview
                                                 withContainerView:self];
    if (mountResult) {
      [self setupViewConstraintsForController:navigationController];
    }
  }
}

// By default, the header buttons that are not inside the native hit area
// cannot be clicked, so we check it by ourselves
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  if (CGRectContainsPoint(_stackCoordinator.navigationController.navigationBar.frame, point)) {
    RNSStackHeaderConfigComponentView *headerConfig = [self requireTopScreenHeaderConfig];
    CGPoint convertedPoint = [self convertPoint:point toView:headerConfig];
    UIView *headerHitTestResult = [headerConfig hitTest:convertedPoint withEvent:event];
    if (headerHitTestResult != nil) {
      return headerHitTestResult;
    }
  }
  return [super hitTest:point withEvent:event];
}

#pragma mark - Communication with StackScreen

- (void)stackScreenChangedActivityMode:(nonnull RNSStackScreenComponentView *)stackScreen
{
  [_stackCoordinator screenDidChangeActivityMode:stackScreen];
}

#pragma mark - RCTComponentViewProtocol

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert([childComponentView isKindOfClass:RNSStackScreenComponentView.class],
            @"[RNScreens] Attempt to mount child of unsupported type: %@, expected %@",
            childComponentView.class,
            RNSStackScreenComponentView.class);

  auto *childScreen = static_cast<RNSStackScreenComponentView *>(childComponentView);
  childScreen.stackHost = self;
  [_stackCoordinator insertScreen:childScreen atIndex:index];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert([childComponentView isKindOfClass:RNSStackScreenComponentView.class],
            @"[RNScreens] Attempt to unmount child of unsupported type: %@, expected %@",
            childComponentView.class,
            RNSStackScreenComponentView.class);

  auto *childScreen = static_cast<RNSStackScreenComponentView *>(childComponentView);
  childScreen.stackHost = nil;
  [_stackCoordinator removeScreen:childScreen];
}

+ (react::ComponentDescriptorProvider)componentDescriptorProvider
{
  return react::concreteComponentDescriptorProvider<react::RNSStackHostComponentDescriptor>();
}

+ (BOOL)shouldBeRecycled
{
  // There won't be tens of instances of this component usually & it's easier for now.
  // We could consider enabling it someday though.
  return NO;
}

#pragma mark - Utils

- (void)setupViewConstraintsForController:(nonnull UIViewController *)controller
{
  // Enable auto-layout to ensure valid size of stack controller view.
  controller.view.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [controller.view.topAnchor constraintEqualToAnchor:self.topAnchor],
    [controller.view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    [controller.view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [controller.view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
  ]];
}

- (RNSStackHeaderConfigComponentView *)requireTopScreenHeaderConfig
{
  UIViewController *topViewController = _stackCoordinator.navigationController.topViewController;
  RCTAssert([topViewController.view isKindOfClass:[RNSStackScreenComponentView class]],
            @"[RNScreens] Expected top screen to be a react component view of type RNSStackScreenComponentView");
  auto screenView = (RNSStackScreenComponentView *)topViewController.view;

  return screenView.headerConfig;
}

#pragma mark - RCTMountingTransactionObserving

- (void)mountingTransactionDidMount:(const facebook::react::MountingTransaction &)transaction
               withSurfaceTelemetry:(const facebook::react::SurfaceTelemetry &)surfaceTelemetry
{
  [_stackCoordinator flushPendingUpdates];
}

#pragma mark - Dynamic frameworks support

// Needed because of this: https://github.com/facebook/react-native/pull/37274
#ifdef RCT_DYNAMIC_FRAMEWORKS
+ (void)load
{
  [super load];
}
#endif // RCT_DYNAMIC_FRAMEWORKS

@end

Class<RCTComponentViewProtocol> RNSStackHostCls(void)
{
  return RNSStackHostComponentView.class;
}
