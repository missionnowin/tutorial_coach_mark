import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/animated_focus_light.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  const TutorialCoachMarkWidget({
    Key? key,
    required this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.paddingContentVertical = 10,
    this.paddingContentHorizontal = 10,
    this.clickTarget,
    this.onClickTargetWithTapPosition,
    this.clickOverlay,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.onClickSkip,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.useSafeArea = true,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.pulseEnable = true,
    this.skipWidget,
    this.rootOverlay = false,
    this.showSkipInLastTarget = false,
    this.imageFilter,
    this.contentWidth,
    this.contentConstraints,
    this.initialFocus = 0,
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final FutureOr Function(TargetFocus)? clickTarget;
  final FutureOr Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;
  final FutureOr Function(TargetFocus)? clickOverlay;
  final Function()? finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final double paddingContentHorizontal;
  final double paddingContentVertical;
  final double? contentWidth;
  final BoxConstraints? contentConstraints;
  final Function()? onClickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool useSafeArea;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;
  final Widget? skipWidget;
  final bool rootOverlay;
  final bool showSkipInLastTarget;
  final ImageFilter? imageFilter;
  final int initialFocus;

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget>
    implements TutorialCoachMarkController {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool showContent = false;
  TargetFocus? currentTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            initialFocus: widget.initialFocus,
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            focusAnimationDuration: widget.focusAnimationDuration,
            unFocusAnimationDuration: widget.unFocusAnimationDuration,
            pulseAnimationDuration: widget.pulseAnimationDuration,
            pulseVariation: widget.pulseVariation,
            pulseEnable: widget.pulseEnable,
            rootOverlay: widget.rootOverlay,
            imageFilter: widget.imageFilter,
            clickTarget: (target) {
              return widget.clickTarget?.call(target);
            },
            clickTargetWithTapPosition: (target, tapDetails) {
              return widget.onClickTargetWithTapPosition
                  ?.call(target, tapDetails);
            },
            clickOverlay: (target) {
              return widget.clickOverlay?.call(target);
            },
            focus: (target) {
              setState(() {
                currentTarget = target;
                showContent = true;
              });
            },
            removeFocus: () {
              setState(() {
                showContent = false;
              });
            },
          ),
          AnimatedOpacity(
            opacity: showContent ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: _buildContents(),
          ),
          _buildSkip()
        ],
      ),
    );
  }

  Widget _buildContents() {
    if (currentTarget == null) {
      return const SizedBox.shrink();
    }

    List<Widget> children = <Widget>[];

    TargetPosition? target;
    try {
      target = getTargetCurrent(
        currentTarget!,
        rootOverlay: widget.rootOverlay,
      );
    } on NotFoundTargetException catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }

    if (target == null) {
      return const SizedBox.shrink();
    }

    final positioned = Offset(
      target.offset.dx,
      target.offset.dy,
    );

    double haloWidth;
    double haloHeight;

    if (currentTarget!.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    double width = 0.0;
    double? top;
    double? bottom;
    double? left;
    double? right;

    final ancestorBox = context.findRenderObject() as RenderBox;
    final ancestorWidth =  ancestorBox.size.width;
    final widthConstraints = widget.contentConstraints?.maxWidth;
    double? positionWidth;

    if (widthConstraints != null) {
      positionWidth = ancestorWidth > widthConstraints ? widthConstraints : ancestorWidth;
    }

    if (widget.contentWidth != null) {
      positionWidth = widget.contentWidth;
    }

    positionWidth ??= width;

    children = currentTarget!.contents!.map<Widget>((i) {
      switch (i.align) {
        case ContentAlign.bottom:
          {
            width = ancestorWidth ;
            top = positioned.dy + haloHeight + widget.paddingContentVertical;
            left = (ancestorWidth  - positionWidth!) / 2;
            right = null;
            bottom = null;
          }
          break;
        case ContentAlign.top:
          {
            width = ancestorWidth ;
            top = null;
            left = (ancestorWidth  - positionWidth!) / 2;
            right = null;
            bottom = (ancestorBox.size.height - positioned.dy) + widget.paddingContentVertical;
          }
          break;
        case ContentAlign.left:
          {
            width = positioned.dx - haloWidth - widget.paddingContentHorizontal;
            left = 0;
            top = positioned.dy - haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.right:
          {
            left = positioned.dx + haloWidth + widget.paddingContentHorizontal;
            top = positioned.dy - haloHeight / 2;
            bottom = null;
            width = ancestorWidth - left!;
          }
          break;
        case ContentAlign.centerRight:
          left = positioned.dx + haloWidth + widget.paddingContentVertical;
          top = positioned.dy + haloHeight / 2 + widget.paddingContentVertical;
          width = ancestorWidth - left!;
          break;
        case ContentAlign.custom:
          {
            left = i.customPosition!.left;
            right = i.customPosition!.right;
            top = i.customPosition!.top;
            bottom = i.customPosition!.bottom;
            width = ancestorWidth;
          }
          break;
      }

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 100),
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        width: positionWidth,
        child: Container(
          alignment: Alignment.center,
          width: widget.contentWidth ?? width,
          constraints: widget.contentConstraints,
          padding: i.padding,
          child: i.builder?.call(context, this) ??
              (i.child ?? const SizedBox.shrink()),
          )
        );
    }).toList();

    return Stack(
      children: children,
    );
  }

  Widget _buildSkip() {
    bool isLastTarget = false;

    if (currentTarget != null) {
      isLastTarget =
          widget.targets.indexOf(currentTarget!) == widget.targets.length - 1;
    }

    if (widget.hideSkip || (isLastTarget && !widget.showSkipInLastTarget)) {
      return const SizedBox.shrink();
    }

    Widget animatedWidget = AnimatedOpacity(
      opacity: showContent ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: skip,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IgnorePointer(
            child: widget.skipWidget ??
                Text(
                  widget.textSkip,
                  style: widget.textStyleSkip,
                ),
          ),
        ),
      ),
    );

    return Align(
      alignment: currentTarget?.alignSkip ?? widget.alignSkip,
      child: (widget.useSafeArea)
          ? SafeArea(child: animatedWidget)
          : animatedWidget,
    );
  }

  @override
  void skip() => widget.onClickSkip?.call();

  @override
  void next() => _focusLightKey.currentState?.next();

  @override
  void previous() => _focusLightKey.currentState?.previous();

  void goTo(int index) => _focusLightKey.currentState?.goTo(index);

  void refresh() {
    safeSetState(() {
      _focusLightKey.currentState?.refresh();
    });
  }

  int? get currentTargetIndex =>
      _focusLightKey.currentState?.currentTargetIndex;
}
