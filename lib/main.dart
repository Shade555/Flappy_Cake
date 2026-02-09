import 'package:flutter/material.dart';
import 'audio/audio_manager.dart';
import 'package:flame/game.dart';
import 'game/flappy_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.instance.init();
  runApp(const FlappyApp());
}

class FlappyApp extends StatelessWidget {
  const FlappyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = FlappyGame();
    return MaterialApp(
      title: "Lydia's_Birthday",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          initialActiveOverlays: const ['MainMenu'],
          overlayBuilderMap: {
            'MainMenu': (context, game) {
              final g = game as FlappyGame;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Center(
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text("Lydia's_Birthday",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<bool>(
                          valueListenable: AudioManager.instance.muted,
                          builder: (context, muted, child) {
                            return ElevatedButton(
                              onPressed: () => AudioManager.instance.toggleMute(),
                              child: Text(muted ? 'Unmute' : 'Mute'),
                            );
                          },
                        ),
                        Text('Best cakes: ' + g.highScore.toString(),
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            g.overlays.add('Fireworks');
                          },
                          child: const Text('Start'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
            'GameOver': (context, game) {
              final g = game as FlappyGame;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Center(
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('You will get ${g.lastScore} cakes',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 12),
                        Text('Best: ${g.highScore}',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                g.restart();
                              },
                              child: const Text('Retry'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                g.overlays.remove('GameOver');
                                g.showMenu();
                              },
                              child: const Text('Menu'),
                            ),
                            const SizedBox(width: 12),
                            ValueListenableBuilder<bool>(
                              valueListenable: AudioManager.instance.muted,
                              builder: (context, muted, child) {
                                return ElevatedButton(
                                  onPressed: () => AudioManager.instance.toggleMute(),
                                  child: Text(muted ? 'Unmute' : 'Mute'),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            'Fireworks': (context, game) {
              final g = game as FlappyGame;
              return _FireworksOverlay(game: g);
            }
          },
        ),
      ),
    );
  }
}

class _FireworksOverlay extends StatefulWidget {
  final FlappyGame game;
  const _FireworksOverlay({required this.game});

  @override
  State<_FireworksOverlay> createState() => _FireworksOverlayState();
}

class _FireworksOverlayState extends State<_FireworksOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<Offset> _points = [];
  final List<Color> _colors = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    for (var i = 0; i < 8; i++) {
      _points.add(Offset((i - 4) * 20.0, -50 + (i % 3) * 10.0));
      _colors.add(Colors.primaries[i % Colors.primaries.length]);
    }
    _ctrl.forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.game.startGame();
        widget.game.overlays.remove('Fireworks');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _FireworksPainter(progress: _ctrl.value, points: _points, colors: _colors),
          );
        },
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double progress;
  final List<Offset> points;
  final List<Color> colors;
  _FireworksPainter({required this.progress, required this.points, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 80);
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final color = colors[i].withOpacity((1 - progress).clamp(0.0, 1.0));
      final paint = Paint()..color = color;
      final pos = center + p * progress * 3;
      final radius = 4.0 + 12.0 * progress;
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) => oldDelegate.progress != progress;
}

