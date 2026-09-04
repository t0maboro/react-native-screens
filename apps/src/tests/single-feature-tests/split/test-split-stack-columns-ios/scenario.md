# Split with Stack columns (iOS, POC)

## Purpose

Proof of concept for hosting Stack v5 directly inside Split columns. A `Stack.Host`
mounted as the only child of a `Split.Column` keeps owning and driving its own
`RNSStackNavigationController`, exactly as a standalone stack does. What differs
is only who places that controller in the view controller hierarchy: instead of
the host attaching it below the nearest ancestor controller, the Split host
installs it as the column's view controller. The stack screens thus become the
column's view controllers and their `Stack.HeaderConfig` is rendered by the
column's navigation bar.

The hand-over goes through a generic protocol, `RNSNavigationControllerProviding`
(`ios/helpers/container/`): the child exposes its container view controller and a
flag telling it that the parent places the controller. Split knows only the
protocol, Stack knows only the protocol.

Target view controller hierarchy, per column:

```
RNSSplitHostController
└── RNSStackNavigationController (owned by Stack.Host; RNSStackNavigationBar)
    ├── RNSStackScreenController (view = RNSStackScreenComponentView, Stack.HeaderConfig)
    └── RNSStackScreenController …
```

A plain column (no provider child) is unchanged:
`RNSSplitNavigationController → RNSSplitScreenController (view = column)`.

The `Split.Column` and `Stack.Host` component views stay out of the UIKit
hierarchy in this mode; the column frame is reported to the shadow tree from
the provided controller's view (KVO on its frame, the mechanism plain columns
already use for origin changes).

## Steps

1. Open the scenario on an iPad. Two columns are shown, each with its own
   large-title header ("Primary 1", "Secondary 1") on its own navigation bar.
2. Tap "Push" in a column. A screen titled "… 2" is pushed with the native
   transition and the back button appears in that column's bar only.
3. Tap "Pop" or the native back button. The screen is popped; the model is
   updated via `onDismiss` / `onNativeDismiss`.

## Out of scope of the POC (expected not to work)

- Content below the header uses a fixed top padding: stack screens are not
  safe area providers, so `SafeAreaView` would ignore the column's navigation
  bar.
- Custom header items extending beyond the native hit area (`hitSlop`) are
  not hit-tested: the host view's `hitTest:` is not in the hierarchy.
- Collapse and expand on compact widths (iPhone, iPad Slide Over): UIKit nests
  the secondary column's navigation controller on top of the primary one.
  Screens pushed onto the primary while collapsed are dropped on expand, a
  screen buried under the nested controller cannot be popped, and a column
  detached by a native back is not re-shown on push.
- Push/pop vs. Split installation ordering is not enforced (React notifies
  mounting observers in an unspecified order).
- Column lifecycle events (`onWillAppear`, …) are not emitted for stack-backed
  columns.
- The `showSecondaryToggleButton` refresh forces the navigation bar visible,
  ignoring header `hidden`.
- Split host controller cleanup on unmount (pre-existing).
