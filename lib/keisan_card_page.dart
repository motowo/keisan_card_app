import 'package:flutter/material.dart';
import 'package:keisan_card_app/keisan_card.dart';
import 'package:keisan_card_app/keisan_card_manager.dart';
import 'package:provider/provider.dart';

class KeisanCardPage extends StatefulWidget {
  KeisanCardPage({Key key}) : super(key: key);
  @override
  _KeisanCardPageState createState() => _KeisanCardPageState();
}

class _KeisanCardPageState extends State<KeisanCardPage> {

  final _keisanCardManager = KeisanCardManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('計算カード'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Provider<KeisanCardManager>.value(
              value: _keisanCardManager,
              child: _StartButton(),
            ),
          ),
          Container(
            child: Provider<KeisanCardManager>.value(
              value: _keisanCardManager,
              child: _TimerText(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Provider<KeisanCardManager>.value(
              value: _keisanCardManager,
              child: _CardLengthText(),
            ),
          ),
          Expanded(
            child: Provider<KeisanCardManager>.value(
              value: _keisanCardManager,
              child: _CardContentText(),
            ),
          ),

        ],
      ),
      floatingActionButton: _buildNextButton(),
    );
  }

  @override
  void dispose() {
    _keisanCardManager.dispose();
    super.dispose();
  }

  Widget _buildNextButton() {
    return StreamBuilder<bool>(
      stream: _keisanCardManager.hasNext,
      builder: (_, snapshot) {
        var _hasNext = snapshot.data ?? false;
        if (_hasNext) {
          return FloatingActionButton(
            onPressed: _keisanCardManager.next,
            child: Icon(Icons.play_arrow),
          );
        } else {
          return FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey,
            child: Icon(Icons.stop),
          );
        }
      },
    );
  }
}

class _CardContentText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _keisanCardManager = Provider.of<KeisanCardManager>(context, listen: false);
    return StreamBuilder<KeisanCard>(
      stream: _keisanCardManager.currentCard,
      builder: (_, snapshot) {
        return _buildKeisanCardText(snapshot.data, _keisanCardManager);
      },
    );
  }

  Widget _buildKeisanCardText(KeisanCard _keisanCard, KeisanCardManager _keisanCardManager) {
    var _multiplier = _keisanCard?.multiplier?.toString() ?? '-';
    var _multiplicand = _keisanCard?.multiplicand?.toString() ?? '-';
    var _answer = _keisanCard?.answer?.toString() ?? '-';
    return Row(
      children: <Widget>[
        _buildParts(_multiplier),
        _buildParts('x'),
        _buildParts(_multiplicand),
        _buildParts('='),
        StreamBuilder<bool>(
          stream: _keisanCardManager.isOpenAnswer,
          builder: (_, snapshot) {
            return _buildAnswer(_answer, snapshot, _keisanCardManager);
          },
        ),
      ],
    );
  }

  Widget _buildParts(_text) {
    return Expanded(child: Center(child: Text(_text, textScaleFactor: 2.4,)));
  }

  Widget _buildAnswer(_answer, snapshot, KeisanCardManager _keisanCardManager) {
    if (snapshot?.data ?? false) {
      return _buildParts(_answer);
    } else {
      return Expanded(
        child: Center(
          child: FloatingActionButton(
            onPressed: () {
              _keisanCardManager.openAnswer.add(true);
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.lightbulb_outline),
          )
        )
      );
    }
  }
}

class _TimerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _keisanCardManager = Provider.of<KeisanCardManager>(context, listen: false);
    return StreamBuilder<Stopwatch>(
      stream: _keisanCardManager.timer,
      builder: (_, snapshot) {
        String _text = '';
        if (snapshot.data != null) {
          int _t = snapshot.data.elapsedMilliseconds;
          int _h = (_t / 60 / 60 / 1000).floor();
          int _m = (_t / 60 / 1000).floor() % 60;
          int _s = (_t / 1000).floor() % 60;
          int _ms = (_t) % 1000;
          _text = '$_h : ${_m.toString().padLeft(2, '0')} : ${_s.toString().padLeft(2, '0')} . ${_ms.toString().padLeft(3, '0')}';
        }
        return Text(_text, textScaleFactor: 2.4);
      },
    );
  }
}

class _CardLengthText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _keisanCardManager = Provider.of<KeisanCardManager>(context, listen: false);
    return StreamBuilder<int>(
      stream: _keisanCardManager.currentIndex,
      builder: (_, snapshot) {
        String _text = '';
        if (snapshot.data != null) {
          _text = '${snapshot.data + 1} / ${_keisanCardManager.maxCardLength}';
        }
        return Text(_text);
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _keisanCardManager = Provider.of<KeisanCardManager>(context, listen: false);
    return StreamBuilder<bool>(
      stream: _keisanCardManager.canStart,
      builder: (_, snapshot) {
        var _canStart = snapshot.data ?? false;
        if (_canStart) {
          return FloatingActionButton(
              onPressed: () {_keisanCardManager.start.add(null);},
              backgroundColor: Colors.blue,
              child: Icon(Icons.directions_run),
            );
        } else {
          return FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.red,
              child: Icon(Icons.directions_walk),
            );
        }
      },
    );
  }
}
