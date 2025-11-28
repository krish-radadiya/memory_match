import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'app.dart';
import 'src/controllers/board_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Put controller (singleton)
  Get.put(BoardController()..initializeBoard());
  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return const MyApp();
      },
    ),
  );
}
