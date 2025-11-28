// lib/src/widgets/memory_card_widget.dart
import 'dart:async';
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

/// MemoryCardWidget
/// - Safe flip animation
/// - Efficient subscriptions: rebuilds only when this card or a few relevant flags change
/// - Loads image assets with fallback to letter
class MemoryCardWidget extends StatefulWidget {
  final int index;

  const MemoryCardWidget({super.key, required this.index});

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final BoardController _board;

  StreamSubscription<dynamic>? _cardsSub;
  StreamSubscription<dynamic>? _busySub;
  StreamSubscription<dynamic>? _gameOverSub;

  // cached snapshot of the card so we only rebuild when it actually changes
  MemoryCard? _cachedCard;
  bool _cachedIsBusy = false;
  bool _cachedGameOver = false;

  bool _initialized = false;
  bool _animatingFromSnapshot = false;

  @override
  void initState() {
    super.initState();
    _board = Get.find<BoardController>();

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: Constants.baseAnimationMs),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // wait until first frame so board.cards is available
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Initialize snapshot if available
      if (_board.cards.length > widget.index) {
        _cachedCard = _cloneCard(_board.cards[widget.index]);
        _ctrl.value = _cachedCard!.isFaceUp ? 1.0 : 0.0;
      } else {
        _cachedCard = null;
      }
      _cachedIsBusy = _board.isBusy.value;
      _cachedGameOver = _board.gameOver.value;
      _initialized = true;

      // subscribe to cards changes and other small flags
      _cardsSub = _board.cards.listen((_) {
        if (!mounted) return;
        _handleCardListChange();
      });

      _busySub = _board.isBusy.listen((val) {
        if (!mounted) return;
        if (val != _cachedIsBusy) {
          _cachedIsBusy = val;
          setState(() {});
        }
      });

      _gameOverSub = _board.gameOver.listen((val) {
        if (!mounted) return;
        if (val != _cachedGameOver) {
          _cachedGameOver = val;
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _cardsSub?.cancel();
    _busySub?.cancel();
    _gameOverSub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // create a small local copy so we can compare easily
  MemoryCard _cloneCard(MemoryCard c) => MemoryCard(id: c.id, pairId: c.pairId, isFaceUp: c.isFaceUp, isMatched: c.isMatched);

  // Called on board.cards changes
  void _handleCardListChange() {
    // if index out of range -> clear cached card and rebuild to hide widget
    if (_board.cards.length <= widget.index) {
      if (_cachedCard != null) {
        _cachedCard = null;
        setState(() {});
      }
      return;
    }

    final current = _board.cards[widget.index];
    final snapshot = _cachedCard;

    // If first time or the relevant fields changed -> update
    if (snapshot == null || snapshot.pairId != current.pairId || snapshot.isFaceUp != current.isFaceUp || snapshot.isMatched != current.isMatched) {
      // schedule animation change after frame if faceUp changed
      if (snapshot != null && snapshot.isFaceUp != current.isFaceUp) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          // avoid triggering animation mid-frame if we already triggered
          _animatingFromSnapshot = true;
          if (current.isFaceUp) {
            _ctrl.forward();
          } else {
            _ctrl.reverse();
          }
          // leave flag - used only to avoid racing; it is safe to reset on next rebuild
          Future.delayed(const Duration(milliseconds: 20), () => _animatingFromSnapshot = false);
        });
      } else if (snapshot == null) {
        // initial set: set controller value, no animation
        _ctrl.value = current.isFaceUp ? 1.0 : 0.0;
      }

      _cachedCard = _cloneCard(current);
      setState(() {});
    }
  }

  void _onTap() {
    // guard against busy/gameOver/matched/faceUp states
    if (_cachedCard == null) return;
    if (_cachedCard!.isFaceUp || _cachedCard!.isMatched) return;
    if (_cachedIsBusy || _cachedGameOver) return;
    _board.selectCardByIndex(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();
    if (_board.cards.length <= widget.index) return const SizedBox.shrink();

    // use the live model for up-to-date values but keep cached for comparisons
    final model = _board.cards[widget.index];
    final CardAsset info = cardAssetMap[model.pairId] ?? cardAssetMap.values.first;
    final Color bgColor = model.isMatched ? AppColors.matched : info.color;
    final bool disabled = model.isFaceUp || model.isMatched || _board.isBusy.value || _board.gameOver.value;

    return GestureDetector(
      onTap: disabled ? null : _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final double angle = _anim.value * pi; // 0..pi
          final bool showFront = angle > (pi / 2);

          final Matrix4 transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective
            ..rotateY(angle);

          final double lift = 6.0 * sin(_anim.value * pi);
          transform.translate(0.0, -lift);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Container(
              margin: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.42), blurRadius: 10, offset: const Offset(0, 6))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: Material(color: Colors.transparent, child: showFront ? _buildFront(model, info, bgColor) : _buildBack()),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(MemoryCard model, CardAsset info, Color bgColor) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // counter-rotate so content is upright
      child: InkWell(
        onTap: (model.isFaceUp || model.isMatched || _board.isBusy.value || _board.gameOver.value) ? null : _onTap,
        splashColor: Colors.white24,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgColor.withOpacity(0.98), bgColor.withOpacity(0.7)],
            ),
          ),
          child: Column(
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
                  child: Text(
                    info.label,
                    style: AppTextStyles.cardLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return InkWell(
      onTap: null,
      splashColor: Colors.white10,
      child: Container(
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
                child: Center(
                  child: Icon(Icons.help_outline_rounded, size: 15.sp, color: Colors.white70),
                ),
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
            // fallback to letter if image missing
            return Text(info.id, style: AppTextStyles.cardLetter.copyWith(color: Colors.white));
          },
        ),
      );
    }
    return Text(info.id, style: AppTextStyles.cardLetter.copyWith(color: Colors.white));
  }
}
