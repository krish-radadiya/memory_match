import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/screens/game_screen.dart';
import 'src/utils/app_colors.dart';
import 'src/utils/app_text_styles.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Memory Match',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.primary,
        textTheme: AppTextStyles.textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBar,
          titleTextStyle: AppTextStyles.appBarTitle,
        ),
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
