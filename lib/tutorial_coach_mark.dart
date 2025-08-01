library tutorial_coach_mark;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

export 'package:tutorial_coach_mark/src/target/target_content.dart';
export 'package:tutorial_coach_mark/src/target/target_focus.dart';
export 'package:tutorial_coach_mark/src/target/target_position.dart';
export 'package:tutorial_coach_mark/src/util.dart';

class TutorialCoachMark {
  final List<TargetFocus> targets;
  final FutureOr<void> Function(TargetFocus)? onClickTarget;
  final FutureOr<void> Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;
  final FutureOr<void> Function(TargetFocus)? onClickOverlay;
  final Function()? onFinish;
  final double paddingFocus;
  final double paddingContentHorizontal;
  final double paddingContentVertical;
  final double? contentWidth;
  final BoxConstraints? contentConstraints;
  // if onSkip return false, the overlay will not be dismissed and call `next`
  final bool Function()? onSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool useSafeArea;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final Duration focusAnimationDuration;
  final Duration unFocusAnimationDuration;
  final Duration pulseAnimationDuration;
  final bool pulseEnable;
  final Widget? skipWidget;
  final bool showSkipInLastTarget;
  final ImageFilter? imageFilter;
  final int initialFocus;
  final ThemeData? themeData;

  OverlayEntry? _overlayEntry;

  TutorialCoachMark({
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onClickTargetWithTapPosition,
    this.onClickOverlay,
    this.onFinish,
    this.paddingFocus = 10,
    this.paddingContentHorizontal = 10,
    this.paddingContentVertical = 10,
    this.contentWidth,
    this.contentConstraints,
    this.onSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.useSafeArea = true,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration = const Duration(milliseconds: 600),
    this.unFocusAnimationDuration = const Duration(milliseconds: 600),
    this.pulseAnimationDuration = const Duration(milliseconds: 500),
    this.pulseEnable = true,
    this.skipWidget,
    this.showSkipInLastTarget = true,
    this.imageFilter,
    this.initialFocus = 0,
    this.themeData,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay({bool rootOverlay = false}) {
    return OverlayEntry(
      builder: (context) {
        return Theme(
          data: themeData ?? Theme.of(context),
          child: TutorialCoachMarkWidget(
            key: _widgetKey,
            targets: targets,
            clickTarget: onClickTarget,
            onClickTargetWithTapPosition: onClickTargetWithTapPosition,
            clickOverlay: onClickOverlay,
            contentConstraints: contentConstraints,
            contentWidth: contentWidth,
            paddingContentHorizontal: paddingContentHorizontal,
            paddingContentVertical: paddingContentVertical,
            paddingFocus: paddingFocus,
            onClickSkip: skip,
            alignSkip: alignSkip,
            skipWidget: skipWidget,
            textSkip: textSkip,
            textStyleSkip: textStyleSkip,
            hideSkip: hideSkip,
            useSafeArea: useSafeArea,
            colorShadow: colorShadow,
            opacityShadow: opacityShadow,
            focusAnimationDuration: focusAnimationDuration,
            unFocusAnimationDuration: unFocusAnimationDuration,
            pulseAnimationDuration: pulseAnimationDuration,
            pulseEnable: pulseEnable,
            finish: finish,
            rootOverlay: rootOverlay,
            showSkipInLastTarget: showSkipInLastTarget,
            imageFilter: imageFilter,
            initialFocus: initialFocus,
          ),
        );
      },
    );
  }

  void show({required BuildContext context, bool rootOverlay = false}) {
    OverlayState? overlay = Overlay.of(context, rootOverlay: rootOverlay);
    overlay.let((it) {
      showWithOverlayState(overlay: it, rootOverlay: rootOverlay);
    });
  }

  // `navigatorKey` needs to be the one that you passed to MaterialApp.navigatorKey
  void showWithNavigatorStateKey({
    required GlobalKey<NavigatorState> navigatorKey,
    bool rootOverlay = false,
  }) {
    navigatorKey.currentState?.overlay.let((it) {
      showWithOverlayState(
        overlay: it,
        rootOverlay: rootOverlay,
      );
    });
  }

  void showWithOverlayState({
    required OverlayState overlay,
    bool rootOverlay = false,
  }) {
    postFrame(() => _createAndShow(overlay, rootOverlay: rootOverlay));
  }

  void _createAndShow(
    OverlayState overlay, {
    bool rootOverlay = false,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay(rootOverlay: rootOverlay);
      overlay.insert(_overlayEntry!);
    }
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    bool removeOverlay = onSkip?.call() ?? true;
    if (removeOverlay) {
      _removeOverlay();
    } else {
      next();
    }
  }

  bool get isShowing => _overlayEntry != null;

  GlobalKey<TutorialCoachMarkWidgetState> get widgetKey => _widgetKey;

  void next() => _widgetKey.currentState?.next();

  void previous() => _widgetKey.currentState?.previous();

  void goTo(int index) => _widgetKey.currentState?.goTo(index);

  void refresh() => _widgetKey.currentState?.refresh();

  int? get currentTargetIndex => _widgetKey.currentState?.currentTargetIndex;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
