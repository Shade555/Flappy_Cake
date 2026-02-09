import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Background extends Component with HasGameRef {
  late Size _screenSize;

  @override
  void onGameResize(Vector2 size) {
    _screenSize = Size(size.x, size.y);
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    final w = _screenSize.width;
    final h = _screenSize.height;
    // vertical darker background gradient (deeper red -> deep pink/purple)
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, h),
        [const Color(0xFF3B0000), const Color(0xFF330022)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // draw gradient text: "Happy Birthday Lydia"
    final text = 'Happy Birthday Lydia';
    final textStyle = TextStyle(
      fontSize: (w / 12).clamp(24.0, 56.0),
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(w * 0.5, 0),
          [Colors.red.shade700, Colors.pink.shade300],
        ),
    );

    // Because mapping to ui.Color is implicit via Color class, TextPainter handles it.
    final textSpan = TextSpan(text: text, style: textStyle);
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    final dx = (w - tp.width) / 2;
    final dy = (h * 0.08).clamp(12.0, 80.0);
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void update(double dt) {}
}
