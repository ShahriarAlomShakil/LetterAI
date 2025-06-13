import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/letter_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const LetterAIApp());
}

class LetterAIApp extends StatelessWidget {
  const LetterAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LetterProvider()),
      ],
      child: MaterialApp(
        title: 'LetterAI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


