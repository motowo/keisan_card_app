import 'dart:async';

import 'package:keisan_card_app/keisan_card.dart';

class KeisanCardManager {
  final _stopWatch = Stopwatch();
  Timer _timer;
  List<KeisanCard> _keisanCard;
  int _currentIndex;

  StreamController _currentCardController;
  StreamController _currentIndexController;
  StreamController _hasNextController;
  StreamController _startFunctionController;
  StreamController _startController;
  StreamController _openAnswerController;
  StreamController _timerController;

  StreamSink<void> get start => _startFunctionController.sink;
  StreamSink<void> get openAnswer => _openAnswerController.sink;

  Stream<KeisanCard> get currentCard => _currentCardController.stream;
  Stream<int> get currentIndex => _currentIndexController.stream;
  Stream<bool> get hasNext => _hasNextController.stream;
  Stream<bool> get canStart => _startController.stream;
  Stream<bool> get isOpenAnswer => _openAnswerController.stream;
  Stream<Stopwatch> get timer => _timerController.stream;
  int get maxCardLength => _keisanCard.length;

  KeisanCardManager() {
    _currentCardController = StreamController<KeisanCard>();
    _currentIndexController = StreamController<int>();
    _hasNextController = StreamController<bool>();
    _startFunctionController = StreamController<void>();
    _startController = StreamController<bool>();
    _openAnswerController = StreamController<bool>();
    _timerController = StreamController<Stopwatch>();

    _startFunctionController.stream.listen((_) => _start());
    _startController.sink.add(true);
  }

  void next() {
    _currentIndex++;
    if (_currentIndex < maxCardLength) {
      _openAnswerController.sink.add(false);
      _updateCurrent();
    } else {
      _hasNextController.sink.add(false);
      _timer.cancel();
      _stopWatch.stop();
      _timerController.sink.add(_stopWatch);
      _startController.sink.add(true);
    }
  }

  void dispose() {
    _currentCardController.close();
    _currentIndexController.close();
    _hasNextController.close();
    _startFunctionController.close();
    _startController.close();
    _openAnswerController.close();
    _timerController.close();
  }

  void _start() {
    _keisanCard = [];
    _currentIndex = 0;
    _buildKuKu();
    _hasNextController.sink.add(true);
    _updateCurrent();
    _stopWatch.reset();
    _stopWatch.start();
    _startController.sink.add(false);
    _openAnswerController.sink.add(false);
    _timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      _timerController.sink.add(_stopWatch);
    });
  }

  void _buildKuKu() {
    for (var i = 1; i <= 9; i++) {
      for (var j = 1; j <= 9; j++) {
        _keisanCard.add(KeisanCard(i, j));
      }
    }
    _keisanCard.shuffle();
  }

  void _updateCurrent() {
    _currentIndexController.sink.add(_currentIndex);
    _currentCardController.sink.add(_keisanCard[_currentIndex]);
  }
}
