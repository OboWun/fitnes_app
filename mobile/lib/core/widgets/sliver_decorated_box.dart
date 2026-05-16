import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverDecoratedBox extends SingleChildRenderObjectWidget {
  /// The decoration to paint behind the sliver child.
  final Decoration decoration;

  const SliverDecoratedBox({
    super.key,
    required this.decoration,
    super.child,
  });

  @override
  RenderSliverDecoratedBox createRenderObject(BuildContext context) {
    return RenderSliverDecoratedBox(
      decoration: decoration,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverDecoratedBox renderObject) {
    renderObject
      ..decoration = decoration
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
  }
}

class RenderSliverDecoratedBox extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
  RenderSliverDecoratedBox({
    required Decoration decoration,
    TextDirection? textDirection,
  }) : _decoration = decoration,
       _textDirection = textDirection {
    _painter = decoration.createBoxPainter(_handlePainterChanged);
  }

  Decoration _decoration;
  TextDirection? _textDirection;
  late BoxPainter _painter;

  Decoration get decoration => _decoration;

  set decoration(Decoration value) {
    if (value == _decoration) return;
    _decoration = value;
    _painter = value.createBoxPainter(_handlePainterChanged);
    markNeedsPaint();
  }

  TextDirection? get textDirection => _textDirection;

  set textDirection(TextDirection? value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  void _handlePainterChanged() {
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    // Delegate layout to the child sliver.
    child!.layout(constraints, parentUsesSize: true);
    geometry = child!.geometry;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null) {
      return child!.hitTest(result, mainAxisPosition: mainAxisPosition, crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final Size size = Size(constraints.crossAxisExtent, geometry!.paintExtent);
    final Rect rect = offset & size;

    final ImageConfiguration config = ImageConfiguration(
      size: size,
      textDirection: _textDirection,
    );

    _painter.paint(context.canvas, rect.topLeft, config);
    context.paintChild(child!, offset);
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }
}
