import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class PipePair extends PositionComponent with HasGameRef {
  final double gapY;
  final double gapHeight;
  final double speed;
  // wider candle to better match collision area
  final double width = 140;
  static const bool SHOW_COLLIDERS = true;
  // tune horizontal inset further so collider is narrower (collisions occur later horizontally)
  final double collisionInsetXPct = 0.42;
  final double collisionInsetYPct = 0.12;
  bool passed = false;
  final String? assetPath;

  late Rect topRect;
  late Rect bottomRect;
  Sprite? spriteTop;
  Sprite? spriteBottom;

  PipePair({required double x, required this.gapY, required this.gapHeight, required this.speed, this.assetPath}) {
    position = Vector2(x, 0);
    size = Vector2(width, 0);
  }

  double get x => position.x;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // build rects based on game size
    final gameH = gameRef.size.y;
    // set component full height so we can render relative to (0,0)
    size = Vector2(width, gameH);
    topRect = Rect.fromLTWH(0, 0, width, gapY);
    bottomRect = Rect.fromLTWH(0, gapY + gapHeight, width, gameH - (gapY + gapHeight));
    // load sprite if an asset path was provided
    if (assetPath != null) {
      try {
        // Flame.Images may prepend an assets directory; avoid duplicate prefixes
        var loadPath = assetPath!;
        loadPath = loadPath.replaceFirst(RegExp(r'^assets/images/'), '');
        final image = await gameRef.images.load(loadPath);
        spriteTop = Sprite(image);
        spriteBottom = Sprite(image);
        // debug
        // ignore: avoid_print
        print('PipePair: loaded asset $assetPath (using $loadPath)');
      } catch (e) {
        spriteTop = null;
        spriteBottom = null;
        // ignore: avoid_print
        print('PipePair: failed to load $assetPath -> $e');
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    // rects remain local; no need to update them here except if gapY changes
    if (position.x + width < -10) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // draw in local coordinates (PositionComponent already applies transform)
    if (spriteTop != null && spriteBottom != null) {
      // draw top sprite rotated 180 degrees
      canvas.save();
      final topCenter = Offset(topRect.left + topRect.width / 2, topRect.top + topRect.height / 2);
      canvas.translate(topCenter.dx, topCenter.dy);
      canvas.rotate(math.pi);
      spriteTop!.renderRect(canvas, Rect.fromLTWH(-topRect.width / 2, -topRect.height / 2, topRect.width, topRect.height));
      canvas.restore();

      // draw bottom sprite normally
      spriteBottom!.renderRect(canvas, bottomRect);
    } else {
      final bodyPaint = Paint()..color = const Color(0xFF2E7D32);
      // draw candle bodies
      canvas.drawRect(topRect, bodyPaint);
      canvas.drawRect(bottomRect, bodyPaint);

      // draw flames near the inner edges of each candle
      final flamePaint = Paint()..color = Colors.yellow;
      // bottom pipe flame (on top of bottom candle)
      final bottomFlameCenter = Offset(bottomRect.center.dx, bottomRect.top + 8);
      canvas.drawCircle(bottomFlameCenter, 6, flamePaint);

      // top pipe flame (on bottom of top candle)
      final topFlameCenter = Offset(topRect.center.dx, topRect.bottom - 8);
      canvas.drawCircle(topFlameCenter, 6, flamePaint);
    }
  }

  bool collidesWith(Rect r) {
    final topAbs = topRect.shift(Offset(position.x, position.y));
    final bottomAbs = bottomRect.shift(Offset(position.x, position.y));
    final collisionInsetXTop = topAbs.width * collisionInsetXPct;
    final collisionInsetYTop = topAbs.height * collisionInsetYPct;
    final collisionInsetXBottom = bottomAbs.width * collisionInsetXPct;
    final collisionInsetYBottom = bottomAbs.height * collisionInsetYPct;

    final topInset = Rect.fromLTWH(
      topAbs.left + collisionInsetXTop,
      topAbs.top + collisionInsetYTop,
      (topAbs.width - collisionInsetXTop * 2).clamp(0, topAbs.width),
      (topAbs.height - collisionInsetYTop * 2).clamp(0, topAbs.height),
    );
    final bottomInset = Rect.fromLTWH(
      bottomAbs.left + collisionInsetXBottom,
      bottomAbs.top + collisionInsetYBottom,
      (bottomAbs.width - collisionInsetXBottom * 2).clamp(0, bottomAbs.width),
      (bottomAbs.height - collisionInsetYBottom * 2).clamp(0, bottomAbs.height),
    );

    if (SHOW_COLLIDERS) {
      // ignore: avoid_print
      print('Pipe top collider: $topInset bottom collider: $bottomInset');
    }

    return r.overlaps(topInset) || r.overlaps(bottomInset);
  }
}
