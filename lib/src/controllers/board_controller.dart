import 'dart:math';
import 'package:get/get.dart';
import '../models/memory_card.dart';
import '../services/timer_service.dart';
import '../utils/constants.dart';

class BoardController extends GetxController {
  final RxList<MemoryCard> cards = <MemoryCard>[].obs;

  final RxnString firstSelectedPair = RxnString();
  final RxnString secondSelectedPair = RxnString();

  final RxBool isBusy = false.obs;
  final RxBool gameOver = false.obs;
  final RxBool gameWon = false.obs;

  final RxInt moves = 0.obs;
  final RxInt matchesFound = 0.obs;

  final TimerService _timerService = TimerService();
  final RxInt elapsedSeconds = 0.obs;

  int _validationToken = 0;

  int maxAttempts = Constants.maxAttempts;
  final RxInt attemptsUsed = 0.obs;

  void initializeBoard({int pairCount = Constants.pairCount}) {
    _validationToken++;
    cards.clear();
    firstSelectedPair.value = null;
    secondSelectedPair.value = null;

    isBusy.value = false;
    gameOver.value = false;
    gameWon.value = false;

    moves.value = 0;
    matchesFound.value = 0;
    attemptsUsed.value = 0;
    elapsedSeconds.value = 0;

    _timerService.reset();
    _timerService.onTick = (s) => elapsedSeconds.value = s;

    final ids = List.generate(pairCount, (i) => String.fromCharCode(65 + i));
    final list = <MemoryCard>[];
    int idCounter = 0;
    for (var pid in ids) {
      list.add(MemoryCard(id: idCounter++, pairId: pid));
      list.add(MemoryCard(id: idCounter++, pairId: pid));
    }
    list.shuffle(Random());
    cards.addAll(list);
  }

  void startTimerIfNeeded() {
    if (elapsedSeconds.value == 0) _timerService.start();
  }

  void selectCardByIndex(int idx) {
    if (gameOver.value) return;
    if (isBusy.value) return;
    if (idx < 0 || idx >= cards.length) return;

    final card = cards[idx];
    if (card.isFaceUp || card.isMatched) return;

    startTimerIfNeeded();

    if (attemptsUsed.value >= maxAttempts) {
      gameOver.value = true;
      _timerService.stop();
      return;
    }

    cards[idx] = card.copyWith(isFaceUp: true);

    if (firstSelectedPair.value == null) {
      firstSelectedPair.value = card.pairId;
      return;
    }

    if (secondSelectedPair.value == null) {
      secondSelectedPair.value = card.pairId;
      moves.value++;
      attemptsUsed.value++;
      _validateMatch();
    }
  }

  void _validateMatch() {
    isBusy.value = true;
    _validationToken++;
    final token = _validationToken;

    final faceUp = <int>[];
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isFaceUp && !cards[i].isMatched) faceUp.add(i);
    }
    if (faceUp.length < 2) {
      isBusy.value = false;
      return;
    }

    final a = faceUp[0];
    final b = faceUp[1];

    final cardA = cards[a];
    final cardB = cards[b];

    if (cardA.pairId == cardB.pairId) {
      cards[a] = cardA.copyWith(isMatched: true);
      cards[b] = cardB.copyWith(isMatched: true);
      matchesFound.value++;
      firstSelectedPair.value = null;
      secondSelectedPair.value = null;
      isBusy.value = false;

      if (matchesFound.value * 2 == cards.length) {
        gameWon.value = true;
        gameOver.value = true;
        _timerService.stop();
      }
      return;
    }

    Future.delayed(Duration(milliseconds: Constants.mismatchDelayMs)).then((_) {
      if (token != _validationToken) return;
      cards[a] = cardA.copyWith(isFaceUp: false);
      cards[b] = cardB.copyWith(isFaceUp: false);
      firstSelectedPair.value = null;
      secondSelectedPair.value = null;
      isBusy.value = false;
      if (attemptsUsed.value >= maxAttempts) {
        gameOver.value = true;
        _timerService.stop();
      }
    });
  }

  void resetBoard() {
    _validationToken++;
    _timerService.reset();
    initializeBoard();
  }

  @override
  void onClose() {
    _timerService.dispose();
    super.onClose();
  }
}
