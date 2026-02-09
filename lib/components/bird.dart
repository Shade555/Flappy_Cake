import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Bird extends PositionComponent with HasGameRef {
  final Vector2 velocity = Vector2.zero();
  final double bodyWidth = 64;
  final double bodyHeight = 48;
  final String? assetPath;
  Sprite? sprite;
  // collision inset proportions (fraction of width/height)
  static const bool SHOW_COLLIDERS = true;
  // tune horizontal inset further so collider is narrower (collisions occur later horizontally)
  final double collisionInsetXPct = 0.45;
  final double collisionInsetYPct = 0.22;

  Bird({this.assetPath = 'assets/images/cake.png'}) {
    size = Vector2(bodyWidth, bodyHeight);
    anchor = Anchor.center;
  }

  double get y => position.y;
  double get x => position.x;

  @override
  void update(double dt) {
    super.update(dt);
    final g = (gameRef as dynamic).gravity as double? ?? 900.0;
    velocity.y += g * dt;
    position += velocity * dt;
    angle = (velocity.y / 1000).clamp(-0.5, 0.8).toDouble();
  }

  void flap() {
    velocity.y = -300;
  }

  Rect toRect() {
    final collisionInsetX = width * collisionInsetXPct;
    final collisionInsetY = height * collisionInsetYPct;
    final left = position.x - width / 2 + collisionInsetX;
    final top = position.y - height / 2 + collisionInsetY;
    final w = (width - collisionInsetX * 2).clamp(0, width).toDouble();
    final h = (height - collisionInsetY * 2).clamp(0, height).toDouble();
    return Rect.fromLTWH(left, top, w, h);
  }
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (assetPath != null) {
      try {
        var loadPath = assetPath!;
        loadPath = loadPath.replaceFirst(RegExp(r'^assets/images/'), '');
        final image = await gameRef.images.load(loadPath);
        sprite = Sprite(image);
        // ignore: avoid_print
        print('Bird: loaded asset $assetPath (using $loadPath)');
        // adjust size to sprite size if possible
        size = Vector2(width, height);
      } catch (e) {
        sprite = null;
        // ignore: avoid_print
        print('Bird: failed to load $assetPath -> $e');
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      // draw centered
      sprite!.renderRect(canvas, Rect.fromLTWH(-width / 2, -height / 2, width, height));
    } else {
      final cakeRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);

      // cake base
      final basePaint = Paint()..color = const Color(0xFFB5651D); // brown
      canvas.drawRRect(RRect.fromRectAndRadius(cakeRect, const Radius.circular(6)), basePaint);

      // frosting stripe
      final frostPaint = Paint()..color = Colors.pinkAccent;
      final frostRect = Rect.fromLTWH(-width / 2, -height / 2, width, height * 0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(frostRect, const Radius.circular(4)), frostPaint);

      // cherry on top
      final cherryPaint = Paint()..color = Colors.redAccent;
      canvas.drawCircle(Offset(0, -height / 2 + 8), 4, cherryPaint);

      // small candle on cake (a rectangle with a flame)
      final candlePaint = Paint()..color = Colors.white;
      final candleRect = Rect.fromLTWH(-6, -height / 2 - 6, 12, 10);
      canvas.drawRRect(RRect.fromRectAndRadius(candleRect, const Radius.circular(2)), candlePaint);
      final flamePaint = Paint()..color = Colors.yellow;
      canvas.drawCircle(Offset(0, -height / 2 - 10), 4, flamePaint);
    }
    if (SHOW_COLLIDERS) {
      // print collider rect for debugging
      // ignore: avoid_print
      print('Bird collider: ${toRect()}');
    }
  }
}
