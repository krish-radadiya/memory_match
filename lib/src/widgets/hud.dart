import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controllers/board_controller.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_strings.dart';

class HUD extends StatelessWidget {
  const HUD({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    return Obx(() {
      final used = controller.attemptsUsed.value;
      final max = controller.maxAttempts;
      final progress = (used / max).clamp(0.0, 1.0);

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.attempts, style: AppTextStyles.hudLabel),
                SizedBox(height: 0.7.h),
                Stack(
                  children: [
                    Container(height: 3.h, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20))),
                    FractionallySizedBox(widthFactor: progress, child: Container(height: 3.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${controller.attemptsUsed.value}/${controller.maxAttempts}', style: AppTextStyles.hudValue),
              SizedBox(height: 0.7.h),
              Text(_formatTime(controller.elapsedSeconds.value), style: AppTextStyles.hudLabel),
            ],
          ),
        ],
      );
    });
  }
}
