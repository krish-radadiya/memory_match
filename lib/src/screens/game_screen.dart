import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controllers/board_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import '../widgets/hud.dart';
import '../widgets/memory_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _overlayCtrl;
  bool _scheduledDialog = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _overlayCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _overlayCtrl.dispose();
    super.dispose();
  }

  void _openWin(BoardController c) {
    _overlayCtrl.forward(from: 0);
    _confetti.play();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!Get.isDialogOpen!) {
        Get.defaultDialog(
          title: "You Win! 🎉",
          content: Text("Nice work — you matched all cards.", style: TextStyle(fontSize: 11.sp), textAlign: TextAlign.center),
          barrierDismissible: false,
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
              c.resetBoard();
            },
            child: Text("Play Again"),
          ),
          cancel: TextButton(onPressed: () => Get.back(), child: Text("Exit", style: TextStyle(color: Colors.red))),
        );
      }
    });
  }

  void _openGameOver(BoardController c) {
    if (!Get.isDialogOpen!) {
      Get.defaultDialog(
        title: "Game Over",
        content: Text("You've used all attempts.", style: TextStyle(fontSize: 11.sp), textAlign: TextAlign.center),
        barrierDismissible: false,
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
            c.resetBoard();
          },
          child: Text("Play Again"),
        ),
        cancel: TextButton(onPressed: () => Get.back(), child: Text("Exit", style: TextStyle(color: Colors.red))),
      );
    }
  }

  void _scheduleDialogIfNeeded(BoardController controller) {
    if (_scheduledDialog) return;
    _scheduledDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledDialog = false;
      if (controller.gameWon.value) {
        _openWin(controller);
        return;
      }
      if (controller.gameOver.value && !controller.gameWon.value && controller.attemptsUsed.value >= controller.maxAttempts) {
        _openGameOver(controller);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();

    return Obx(() {
      if ((controller.gameWon.value || (controller.gameOver.value && controller.attemptsUsed.value >= controller.maxAttempts))) {
        _scheduleDialogIfNeeded(controller);
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            appBar: AppBar(
              // backgroundColor: AppColors.appBar,
              elevation: 0,
              centerTitle: true,
              // title: _buildTitleWidget(),
              actions: [
                IconButton(icon: Icon(Icons.refresh, size: 18.sp), onPressed: () => controller.resetBoard())
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 1.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      children: [
                        Text(AppStrings.title, style: AppTextStyles.title, textAlign: TextAlign.center),
                        SizedBox(height: 1.h),
                        Text(AppStrings.subtitle, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
                        SizedBox(height: 2.h),
                        const HUD(),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: const MemoryBoard())),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
                shouldLoop: false,
              ),
            ),
          ),

          if (controller.gameWon.value)
            AnimatedBuilder(
              animation: _overlayCtrl,
              builder: (context, child) {
                final t = Curves.elasticOut.transform(_overlayCtrl.value);
                return Opacity(
                  opacity: _overlayCtrl.value,
                  child: Transform.scale(scale: 0.8 + 0.6 * t, child: child),
                );
              },
              child: Center(
                child: Container(
                  width: 70.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white24, Colors.white10]),
                    borderRadius: BorderRadius.circular(5.w),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20)],
                  ),
                  alignment: Alignment.center,
                  // child: Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Text("YOU WIN!", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                  //     SizedBox(height: 2.h),
                  //     Text("All matched — congrats!", style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
                  //   ],
                  // ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTitleWidget() {
    // show image if present, otherwise text
    final image = Image.asset('assets/images/title_logo.png', height: 6.h, errorBuilder: (c, e, s) {
      return Text(AppStrings.title, style: AppTextStyles.appBarTitle);
    });
    return image;
  }
}
