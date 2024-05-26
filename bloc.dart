import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GameEvent {}

class OnInitialiseGame extends GameEvent {}

class OnStartGame extends GameEvent {}

class OnScreenTapped extends GameEvent {}

class OnUpdateGameProgress extends GameEvent {}

abstract class GameState {}

class ShowSplashScreen extends GameState {}

class GameProgressUpdated extends GameState {
  final double birdYaxis;
  final double barrierXOne;
  final bool isStartGame;
  final bool isBarrierTouched;
  final double barrierXTwo;
  final int score;
  final int bestScore;

  GameProgressUpdated({
    required this.birdYaxis,
    required this.barrierXOne,
    required this.isStartGame,
    required this.isBarrierTouched,
    required this.barrierXTwo,
    required this.score,
    required this.bestScore,
  });
}

//Bloc
class GameBloc extends Bloc<GameEvent, GameState> {
  double time = 0;
  double height = 0;
  double initialHeight = 0;
  bool isStartGame = false;
  bool isBarrierTouched = false;
  double birdYaxis = 0;
  double barrierXOne = 0;
  double barrierXTwo = 0;
  int score = 0;
  int bestScore = 0;
  late SharedPreferences pref;

  GameBloc() : super(ShowSplashScreen());

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    if (event is OnInitialiseGame) {
      pref = await SharedPreferences.getInstance();
      bestScore = pref.getInt("HighScore") ?? 0;
      await Future.delayed(const Duration(seconds: 2));

      barrierXOne = 0.9;
      barrierXTwo = barrierXOne + 1.8;

      yield GameProgressUpdated(
        birdYaxis: birdYaxis,
        barrierXOne: barrierXOne,
        isStartGame: isStartGame,
        isBarrierTouched: isBarrierTouched,
        barrierXTwo: barrierXTwo,
        score: score,
        bestScore: bestScore,
      );
    }

    if (event is OnStartGame) {
      time = 0;
      height = 0;
      initialHeight = 0;
      isStartGame = false;
      score = 0;
      barrierXOne = 0.9;
      barrierXTwo = barrierXOne + 1.8;
      isBarrierTouched = false;
      startGame();
    }

    if (event is OnScreenTapped) {
      time = 0;
      initialHeight = birdYaxis;
    }

    if (event is OnUpdateGameProgress) {
      yield GameProgressUpdated(
        birdYaxis: birdYaxis,
        barrierXOne: barrierXOne,
        isStartGame: isStartGame,
        isBarrierTouched: isBarrierTouched,
        barrierXTwo: barrierXTwo,
        score: score,
        bestScore: bestScore,
      );
    }
  }

  static Future<void> gameSound(String source) async {
    AudioPlayer player = AudioPlayer();
    player.play(AssetSource(source));
  }

  void startGame() {
    isStartGame = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      time = time + 0.02;
      height = (-4.9 * (time * time)) + 2.3 * time;
      birdYaxis = initialHeight - height;

      if (barrierXOne < -2) {
        barrierXOne += 3.5;
      } else {
        barrierXOne -= 0.05;
      }

      if (barrierXTwo < -2) {
        barrierXTwo += 3.5;
      } else {
        barrierXTwo -= 0.05;
      }

      if (barrierXOne < -0.75 && barrierXOne > -0.79) {
        gameSound("point.mp3");
        score += 1;
      }

      if (barrierXTwo < -0.74 && barrierXTwo > -0.78) {
        gameSound("point.mp3");
        score += 1;
      }

      // Adjust the Y-axis boundaries for collision detection
      if (barrierXOne < -0.2 && barrierXOne > -0.78) {
        if (birdYaxis < -0.5 || birdYaxis > 0.4) {
          isBarrierTouched = true;
        }
      }

      if (barrierXTwo < -0.19 && barrierXTwo > -0.74) {
        if (birdYaxis < -0.2 || birdYaxis > 0.75) {
          isBarrierTouched = true;
        }
      }

      if (birdYaxis >= 1 || isBarrierTouched) {
        timer.cancel();
        isStartGame = false;
        bestScore = score > bestScore ? score : bestScore;
        await pref.setInt("HighScore", bestScore);
      }
      add(OnUpdateGameProgress());
    });
  }
}
