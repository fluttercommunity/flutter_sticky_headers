// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import './render.dart';

/// Builder called during layout to allow the header's content to be animated or styled based
/// on the amount of stickyness the header has.
///
/// [context] for your build operation.
///
/// [stuckAmount] will have the value of:
/// ```
///   0.0 <= value <= 1.0: about to be stuck
///          0.0 == value: at top
///  -1.0 >= value >= 0.0: past stuck
/// ```
///
typedef Widget StickyHeaderWidgetBuilder(BuildContext context, double stuckAmount);

/// Stick Header Widget
///
/// Will layout the [header] above the [content] unless the [overlapHeaders] boolean is set to true.
/// The [header] will remain stuck to the top of its parent [Scrollable] content.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeader extends MultiChildRenderObjectWidget {
  /// Constructs a new [StickyHeader] widget.
  StickyHeader({
    Key key,
    @required this.header,
    @required this.content,
    this.overlapHeaders: false,
    this.controller,
    this.callback,
  }) : super(
          key: key,
          // Note: The order of the children must be preserved for the RenderObject.
          children: [content, header],
        );

  /// Header to be shown at the top of the parent [Scrollable] content.
  final Widget header;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// Optional [ScrollController] that will be used by the widget instead of the default inherited one.
  final ScrollController controller;

  /// Optional callback with stickyness value. If you think you need this, then you might want to
  /// consider using [StickyHeaderBuilder] instead.
  final RenderStickyHeaderCallback callback;

  @override
  RenderStickyHeader createRenderObject(BuildContext context) {
    final scrollPosition = this.controller?.position ?? Scrollable.of(context).position;
    assert(scrollPosition != null);
    return RenderStickyHeader(
      scrollPosition: scrollPosition,
      callback: this.callback,
      overlapHeaders: this.overlapHeaders,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStickyHeader renderObject) {
    final scrollPosition = this.controller?.position ?? Scrollable.of(context).position;
    assert(scrollPosition != null);
    renderObject
      ..scrollPosition = scrollPosition
      ..callback = this.callback
      ..overlapHeaders = this.overlapHeaders;
  }
}

/// Sticky Header Builder Widget.
///
/// The same as [StickyHeader] but instead of supplying a Header view, you supply a [builder] that
/// constructs the header with the appropriate stickyness.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeaderBuilder extends StatefulWidget {
  /// Constructs a new [StickyHeaderBuilder] widget.
  const StickyHeaderBuilder({
    Key key,
    @required this.builder,
    this.content,
    this.overlapHeaders: false,
    this.controller,
  }) : super(key: key);

  /// Called when the sticky amount changes for the header.
  /// This builder must not return null.
  final StickyHeaderWidgetBuilder builder;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// Optional [ScrollController] that will be used by the widget instead of the default inherited one.
  final ScrollController controller;

  @override
  _StickyHeaderBuilderState createState() => _StickyHeaderBuilderState();
}

class _StickyHeaderBuilderState extends State<StickyHeaderBuilder> {
  double _stuckAmount;

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      overlapHeaders: widget.overlapHeaders,
      header: LayoutBuilder(
        builder: (context, _) => widget.builder(context, _stuckAmount ?? 0.0),
      ),
      content: widget.content,
      controller: widget.controller,
      callback: (double stuckAmount) {
        if (_stuckAmount != stuckAmount) {
          _stuckAmount = stuckAmount;
          WidgetsBinding.instance.endOfFrame.then((_) {
            if(mounted){
              setState(() {});
            }
          });
        }
      },
    );
  }
}
