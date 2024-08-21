import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:chat_bot/Constants.dart';
import 'package:chat_bot/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset("Animations/Animation.json",
            height: double.infinity, width: double.infinity),
      ),
      duration: 3000,
      splashTransition: SplashTransition.sizeTransition,
      backgroundColor: backgroundcolor,
      nextScreen: const MyHomePage(title: 'G.P.T'),
    );
  }
}
