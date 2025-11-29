// lib/src/widgets/memory_card_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/scheduler.dart';
import '../controllers/board_controller.dart';
import '../models/memory_card.dart';
import '../utils/constants.dart';
import '../utils/app_text_styles.dart';
import '../utils/card_assets.dart';
import '../utils/app_colors.dart';

class MemoryCardWidget extends StatefulWidget {
  final int index;
  const MemoryCardWidget({super.key, required this.index});

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  // track last known faceUp state to trigger animation only when changed
  bool _lastFaceUp = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: Constants.baseAnimationMs));
    // _anim goes 0..pi, so later we can use it directly as angle
    _anim = Tween<double>(begin: 0.0, end: pi).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // mark initialized after first frame so controller and board are ready
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initialized = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    final board = Get.find<BoardController>();
    if (board.cards.length <= widget.index) return;
    final card = board.cards[widget.index];
    if (card.isFaceUp || card.isMatched) return;
    if (board.isBusy.value || board.gameOver.value) return;
    board.selectCardByIndex(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final double corner = 2.w;
    final double margin = 1.w;

    // Use GetX so we get reactive rebuilds. IMPORTANT: read Rx fields explicitly
    return GetX<BoardController>(builder: (controller) {
      // explicit reads so GetX can detect dependencies
      final int cardsLen = controller.cards.length;
      final bool busyFlag = controller.isBusy.value;
      final bool gameOverFlag = controller.gameOver.value;

      // Guard: not initialized yet or index out of range
      if (!_initialized || cardsLen <= widget.index) return const SizedBox.shrink();

      // access the model (index read is okay because we've already read controller.cards above)
      final MemoryCard model = controller.cards[widget.index];

      // schedule flip animation change AFTER build (so we don't mutate controllers during build)
      if (model.isFaceUp != _lastFaceUp) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _lastFaceUp = model.isFaceUp;
          if (model.isFaceUp) {
            _ctrl.forward();
          } else {
            _ctrl.reverse();
          }
        });
      }

      final CardAsset info = cardAssetMap[model.pairId] ?? cardAssetMap.values.first;
      final Color bgColor = info.color; // keep original bg color even when matched
      final bool disabled = model.isFaceUp || model.isMatched || busyFlag || gameOverFlag;

      return GestureDetector(
        onTap: disabled ? null : _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final double angle = _anim.value; // already 0..pi
            final bool showFront = angle > (pi / 2);

            // 3D transform with perspective
            final Matrix4 transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle);

            // subtle lift during flip
            final double lift = 6.0 * sin((angle / pi) * pi);
            transform.translate(0.0, -lift);

            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: Container(
                margin: EdgeInsets.all(margin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(corner),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.42),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(corner),
                  child: Material(
                    color: Colors.transparent,
                    child: showFront ? _buildFront(model, info, bgColor) : _buildBack(),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFront(MemoryCard model, CardAsset info, Color bgColor) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // counter-rotate content so it's upright
      child: InkWell(
        onTap: (model.isFaceUp || model.isMatched || Get.find<BoardController>().isBusy.value || Get.find<BoardController>().gameOver.value)
            ? null
            : _onTap,
        splashColor: Colors.white24,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgColor.withOpacity(0.98), bgColor.withOpacity(0.7)],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.2, -0.3),
                            colors: [Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.02)],
                            radius: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 12, offset: const Offset(-2, -2)),
                            BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(child: _buildCenterImage(info)),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(info.label, style: AppTextStyles.cardLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),

              // matched overlay (keeps original color)
              // if (model.isMatched)
              //   Positioned.fill(
              //     child: Container(
              //       color: AppColors.matchedOverlay,
              //       child: Center(
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Icon(Icons.check_circle, color: Colors.white.withOpacity(0.95), size: 18.sp),
              //             SizedBox(height: 1.h),
              //             Text('Matched', style: AppTextStyles.cardLabel.copyWith(color: Colors.white70)),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.9),
          end: Alignment(0.9, 1.0),
          colors: [Color(0xFF2E3138), Color(0xFF1F2126), Color(0xFF111317)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 30.w,
              height: 12.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.03)],
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(3.w), bottomRight: Radius.circular(4.w)),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0.06)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 10))],
              ),
              child: Center(child: Icon(Icons.help_outline_rounded, size: 15.sp, color: Colors.white70)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 10.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterImage(CardAsset info) {
    final String path = info.asset;
    if (path.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(1.2.w),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          width: 14.w,
          height: 14.w,
          errorBuilder: (context, error, stackTrace) {
            return Text(info.id, style: AppTextStyles.cardLetter.copyWith(color: Colors.white));
          },
        ),
      );
    }
    return Text(info.id, style: AppTextStyles.cardLetter.copyWith(color: Colors.white));
  }
}
