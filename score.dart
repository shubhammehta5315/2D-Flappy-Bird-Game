import 'package:flutter/material.dart';

class ScoreTexts extends StatelessWidget {
  final String title;
  final String subTitle;

  ScoreTexts({required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          subTitle,
          style: const TextStyle(
            color: textColor,
            fontSize: 35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
