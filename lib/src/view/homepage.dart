import 'package:flutter/material.dart';
import 'package:impossible_game/src/controller/audio_controller.dart';
import 'package:provider/provider.dart';
import '../controller/game_controller.dart';
import 'game_window.dart';

/// Homepage scaffold, first loaded when app loads
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // allows control of sound effects and background music
  late AudioController audioController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioController = context.watch<AudioController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            StartButton(),
            const SizedBox(height: 10),
            Text(
              "How to play:",
              style: TextStyle(
                fontSize: 28,
                fontFamily: "Saira",
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "Study the path carefully! Once you tap the first tile, the path disappears—can you remember the sequence and click the tiles in the correct order?",
              style: TextStyle(fontFamily: "Saira"),
            ),
            const SizedBox(height: 10),
            Text(
              "Toggle Background Music",
              style: TextStyle(fontFamily: "Saira"),
            ),
            IconButton(
              onPressed: () {
                audioController.toggleAudio();
              },
              icon:
                  audioController.audioEnabled
                      ? Icon(Icons.volume_up)
                      : Icon(Icons.volume_off),
            ),
            const SizedBox(height: 20),
            Text(
              "Credits:",
              style: TextStyle(fontSize: 28, fontFamily: "Saira"),
            ),
            Text(
              "Thankyou to Pixabay for Music and SFX\nDeveloped by NovaForge",
              style: TextStyle(fontFamily: "Saira"),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated start button used on the homepage
class StartButton extends StatefulWidget {
  @override
  _StartButtonState createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 8.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AudioController audioController = context.watch<AudioController>();
    GameController gameController = context.watch<GameController>();
    return TextButton(
      onPressed: () {
        if (audioController.audioEnabled) {
          audioController.playBackgroundMusic();
        }
        gameController.generatePath();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameWindow()),
        );
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(16.0),
            width: 200,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.6),
                  blurRadius: _animation.value,
                  spreadRadius: _animation.value / 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Start',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurple,
                  fontFamily: "Saira",
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
