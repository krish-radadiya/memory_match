import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controllers/board_controller.dart';
import 'memory_card_widget.dart';
import '../utils/constants.dart';

class MemoryBoard extends StatelessWidget {
  const MemoryBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    return Obx(() {
      final itemCount = controller.cards.length;
      final cross = Constants.columns;
      return LayoutBuilder(builder: (context, constraints) {
        final spacing = 3.w;
        final totalSpacing = spacing * (cross - 1);
        final tileWidth = (constraints.maxWidth - totalSpacing) / cross;
        final tileHeight = tileWidth * 1.08; // slightly shorter cards
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 1.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: tileWidth / tileHeight,
          ),
          itemCount: itemCount,
          itemBuilder: (_, index) {
            final id = (index < controller.cards.length) ? controller.cards[index].id : -1;
            return MemoryCardWidget(index: index, key: ValueKey("card-$id"));
          },
        );
      });
    });
  }
}
