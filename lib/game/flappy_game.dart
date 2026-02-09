import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/bird.dart';
import '../components/pipe_pair.dart';
import '../components/ground.dart';
import '../components/background.dart';
import '../audio/audio_manager.dart';

class FlappyGame extends FlameGame with TapDetector {
  late Bird bird;
  late TextComponent scoreText;

  final double gravity = 900; // px/s^2
  final double pipeSpeed = 200; // px/s
  final String? pipeAsset = 'assets/images/candle.png';

  double _spawnTimer = 0;
  final double spawnInterval = 1.6;

  int score = 0;
  bool isGameOver = false;
  int highScore = 0;
  int lastScore = 0;
  late SharedPreferences _prefs;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _prefs = await SharedPreferences.getInstance();
    highScore = _prefs.getInt('highScore') ?? 0;
    // add fixed background
    add(Background());
    // Use default viewport to avoid dependency on specific Flame viewport APIs.
    // add ground
    final groundHeight = 24.0;
    final ground = Ground(heightPx: groundHeight)
      ..position = Vector2(0, size.y - groundHeight)
      ..size = Vector2(size.x, groundHeight);
    add(ground);
    bird = Bird()
      ..position = Vector2(size.x * 0.2, size.y / 2)
      ..anchor = Anchor.center;
    add(bird);

    scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 28)),
    )..position = Vector2(12, 12);
    add(scoreText);

    // start paused with menu overlay visible from UI side
    pauseEngine();
    // refresh main menu overlay so it shows loaded high score
    if (overlays.isActive('MainMenu')) {
      overlays.remove('MainMenu');
      overlays.add('MainMenu');
    }
  }

  @override
  void onTap() {
    if (isGameOver) {
      restart();
    } else {
      bird.flap();
    }
  }

  void restart() {
    isGameOver = false;
    score = 0;
    scoreText.text = '0';
    // remove pipes
    children.whereType<PipePair>().toList().forEach((p) => p.removeFromParent());
    // reset bird
    bird.position = Vector2(size.x * 0.2, size.y / 2);
    bird.velocity.setZero();
    // resume engine
    resumeEngine();
    overlays.remove('GameOver');
  }

  void startGame() {
    // start fresh
    restart();
    overlays.remove('MainMenu');
    resumeEngine();
    // start background music (will respect muted state)
    AudioManager.instance.playLoop();
  }

  void showMenu() {
    pauseEngine();
    overlays.add('MainMenu');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    _spawnTimer += dt;
    if (_spawnTimer > spawnInterval) {
      _spawnTimer = 0;
      // increased gap to make the game a bit easier
      // gap scales with screen height to be more forgiving on larger screens
      final gap = (size.y * 0.32).clamp(180.0, 320.0);
      final minY = 80.0;
      final maxY = size.y - 200.0 - gap;
      final gapY = Random().nextDouble() * (maxY - minY) + minY;
      add(PipePair(x: size.x + 40, gapY: gapY, gapHeight: gap, speed: pipeSpeed, assetPath: pipeAsset));
    }

    // scoring & collisions
    for (final pipe in children.whereType<PipePair>()) {
      if (!pipe.passed && pipe.x + pipe.width < bird.x) {
        pipe.passed = true;
        score++;
        scoreText.text = score.toString();
      }

      if (pipe.collidesWith(bird.toRect())) {
        gameOver();
      }
    }

    // ground collision: immediate restart when touching ground
    final groundList = children.whereType<Ground>().toList();
    if (groundList.isNotEmpty) {
      final groundComp = groundList.first;
      if (bird.toRect().overlaps(groundComp.rect)) {
        gameOver();
        return;
      }
    }

    // ceiling
    if (bird.y - bird.height / 2 <= 0) {
      gameOver();
    }
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    // update last/high score and persist
    lastScore = score;
    if (score > highScore) {
      highScore = score;
      _prefs.setInt('highScore', highScore);
    }
    // show overlay and pause
    overlays.add('GameOver');
    pauseEngine();
  }
}
