#import "RNSStackCoordinator.h"
#import <React/RCTAssert.h>
#import "RNSLog.h"
#import "RNSStackNavigationController.h"
#import "RNSStackOperation.h"
#import "RNSStackScreenComponentView.h"

@implementation RNSStackCoordinator {
  NSMutableArray<RNSStackScreenComponentView *> *_Nonnull _renderedScreens;
  NSMutableArray<RNSPushOperation *> *_Nonnull _pendingPushOperations;
  NSMutableArray<RNSPopOperation *> *_Nonnull _pendingPopOperations;
}

- (instancetype)init
{
  if (self = [super init]) {
    [self initState];
  }
  return self;
}

- (void)initState
{
  _navigationController = [RNSStackNavigationController new];
  _renderedScreens = [NSMutableArray array];
  _pendingPushOperations = [NSMutableArray array];
  _pendingPopOperations = [NSMutableArray array];
}

#pragma mark - Screens

- (void)insertScreen:(nonnull RNSStackScreenComponentView *)screen atIndex:(NSInteger)index
{
  [_renderedScreens insertObject:screen atIndex:index];
  if (screen.activityMode == RNSStackScreenActivityModeAttached) {
    [self addPushOperation:screen];
  }
}

- (void)removeScreen:(nonnull RNSStackScreenComponentView *)screen
{
  [_renderedScreens removeObject:screen];
  if (screen.activityMode == RNSStackScreenActivityModeAttached && !screen.isNativelyDismissed) {
    // This shouldn't happen in typical scenarios but it can happen with fast-refresh.
    [self addPopOperation:screen];
  } else {
    RNSLog(@"[RNScreens] ignoring pop operation of %@, already not attached or natively dismissed", screen.screenKey);
  }
}

- (void)screenDidChangeActivityMode:(nonnull RNSStackScreenComponentView *)screen
{
  RCTAssert(screen != nil, @"[RNScreens] Expected non nill stackScreen");
  switch (screen.activityMode) {
    case RNSStackScreenActivityModeAttached:
      [self addPushOperation:screen];
      break;
    case RNSStackScreenActivityModeDetached:
      [self addPopOperation:screen];
      break;
    default:
      RCTAssert(NO, @"[RNScreens] Unexpected value of activityMode: %d", screen.activityMode);
      return;
  }
}

#pragma mark - Operations

- (BOOL)hasPendingOperations
{
  return _pendingPushOperations.count > 0 || _pendingPopOperations.count > 0;
}

- (void)addPushOperation:(nonnull RNSStackScreenComponentView *)stackScreen
{
  RNSPushOperation *operation = [[RNSPushOperation alloc] initWithScreen:stackScreen];
  [_pendingPushOperations addObject:operation];
}

- (void)addPopOperation:(nonnull RNSStackScreenComponentView *)stackScreen
{
  RNSPopOperation *operation = [[RNSPopOperation alloc] initWithScreen:stackScreen];
  [_pendingPopOperations addObject:operation];
}

- (void)flushPendingUpdates
{
  if (![self hasPendingOperations]) {
    return;
  }

  auto popOperations = [[[self orderedOperations:(NSMutableArray<RNSStackOperation *> *)_pendingPopOperations]
      reverseObjectEnumerator] allObjects];

  for (RNSStackOperation *operation in popOperations) {
    [_navigationController enqueuePopOperation:static_cast<RNSPopOperation *>(operation).stackScreen];
  }

  auto pushOperations = [self orderedOperations:(NSMutableArray<RNSStackOperation *> *)_pendingPushOperations];

  for (RNSStackOperation *operation in pushOperations) {
    [_navigationController enqueuePushOperation:static_cast<RNSPushOperation *>(operation).stackScreen];
  }

  [_navigationController performContainerUpdateIfNeeded];

  [_pendingPopOperations removeAllObjects];
  [_pendingPushOperations removeAllObjects];
}

/** @brief Orders the operations by the React index of their screens. */
- (NSArray<RNSStackOperation *> *)orderedOperations:(nonnull NSMutableArray<RNSStackOperation *> *)operations
{
  NSArray<RNSStackScreenComponentView *> *renderedScreens = _renderedScreens;
  return [operations sortedArrayUsingComparator:^NSComparisonResult(RNSStackOperation *obj1, RNSStackOperation *obj2) {
    return [@([renderedScreens indexOfObject:obj1.stackScreen])
        compare:@([renderedScreens indexOfObject:obj2.stackScreen])];
  }];
}

@end
