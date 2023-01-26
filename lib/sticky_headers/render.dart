// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'dart:math' show min, max;
import 'dart:ui' as ui show window;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Called every layout to provide the amount of stickyness a header is in.
/// This lets the widgets animate their content and provide feedback.
///
typedef RenderStickyHeaderCallback = void Function(double stuckAmount);

/// RenderObject for StickyHeader widget.
///
/// Monitors given [Scrollable] and adjusts its layout based on its offset to
/// the scrollables' [RenderObject]. The header will be placed above content
/// unless overlapHeaders is set to true. The supplied callback will be used
/// to report the
///
class RenderStickyHeader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderStickyHeaderCallback? _callback;
  ScrollPosition _scrollPosition;
  bool _overlapHeaders;

  double headerHeight = 0.0;

  RenderStickyHeader({
    required ScrollPosition scrollPosition,
    RenderStickyHeaderCallback? callback,
    bool overlapHeaders = false,
    RenderBox? header,
    RenderBox? content,
  })  : _scrollPosition = scrollPosition,
        _callback = callback,
        _overlapHeaders = overlapHeaders {
    if (content != null) add(content);
    if (header != null) add(header);
  }

  set scrollPosition(ScrollPosition newValue) {
    if (_scrollPosition == newValue) {
      return;
    }
    final ScrollPosition oldValue = _scrollPosition;
    _scrollPosition = newValue;
    markNeedsPaint();
    if (attached) {
      oldValue.removeListener(markNeedsPaint);
      newValue.addListener(markNeedsPaint);
    }
  }

  set callback(RenderStickyHeaderCallback? newValue) {
    if (_callback == newValue) {
      return;
    }
    _callback = newValue;
    markNeedsPaint();
  }

  set overlapHeaders(bool newValue) {
    if (_overlapHeaders == newValue) {
      return;
    }
    _overlapHeaders = newValue;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollPosition.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scrollPosition.removeListener(markNeedsPaint);
    super.detach();
  }

  // short-hand to access the child RenderObjects
  RenderBox get _headerBox => lastChild!;

  RenderBox get _contentBox => firstChild!;

  double get devicePixelRatio => ui.window.devicePixelRatio;

  double roundToNearestPixel(double offset) {
    return (offset * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }

  @override
  void performLayout() {
    // layout both header and content widget
    final childConstraints = constraints.loosen();
    _headerBox.layout(childConstraints, parentUsesSize: true);
    _contentBox.layout(childConstraints, parentUsesSize: true);

    headerHeight = roundToNearestPixel(_headerBox.size.height);
    final contentHeight = roundToNearestPixel(_contentBox.size.height);

    // determine size of ourselves based on content widget
    final width = constraints.constrainWidth(
      max(constraints.minWidth, _contentBox.size.width),
    );
    final height = constraints.constrainHeight(
      max(constraints.minHeight,
          _overlapHeaders ? contentHeight : headerHeight + contentHeight),
    );
    size = Size(width, height);

    // place content underneath header
    final contentParentData =
        _contentBox.parentData as MultiChildLayoutParentData;
    contentParentData.offset =
        Offset(0.0, _overlapHeaders ? 0.0 : headerHeight);
  }

  double determineStuckOffset() {
    final scrollBox =
        _scrollPosition.context.notificationContext!.findRenderObject();
    if (scrollBox?.attached ?? false) {
      try {
        return localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      } catch (e) {
        // ignore and fall-through and return 0.0
      }
    }
    return 0.0;
  }

  @override
  void setupParentData(RenderObject child) {
    super.setupParentData(child);
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _contentBox.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _contentBox.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _overlapHeaders
        ? _contentBox.getMinIntrinsicHeight(width)
        : (_headerBox.getMinIntrinsicHeight(width) +
            _contentBox.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _overlapHeaders
        ? _contentBox.getMaxIntrinsicHeight(width)
        : (_headerBox.getMaxIntrinsicHeight(width) +
            _contentBox.getMaxIntrinsicHeight(width));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result as BoxHitTestResult,
        position: position);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // determine by how much the header should be stuck to the top
    final double stuckOffset = roundToNearestPixel(determineStuckOffset());

    // place header over content relative to scroll offset
    final double maxOffset = size.height - headerHeight;
    final headerParentData =
        _headerBox.parentData as MultiChildLayoutParentData;
    headerParentData.offset =
        Offset(0.0, max(0.0, min(-stuckOffset, maxOffset)));

    // report to widget how much the header is stuck.
    if (_callback != null) {
      final stuckAmount =
          max(min(headerHeight, stuckOffset), -headerHeight) / headerHeight;
      _callback!(stuckAmount);
    }

    defaultPaint(context, offset);
  }
}
