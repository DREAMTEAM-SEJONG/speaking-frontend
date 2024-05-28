import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Record extends StatefulWidget {
  final String roomNumber;
  const Record({super.key, required this.roomNumber});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  int _timerSeconds = 0;
  late Timer _timer;

  Future<void> _sendMessage() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (_lastWords != '' && user != null) {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('lecture').doc(user.uid);
      DocumentReference roomDoc =
      userDoc.collection('rooms').doc(widget.roomNumber.toString());

      final docSnapshot = await roomDoc.get();
      if (!docSnapshot.exists) {
        await roomDoc.set({
          'room': widget.roomNumber,
        });
      }

      CollectionReference messagesCollection = roomDoc.collection('message');
      await messagesCollection.add({
        'user_id': user.uid,
        'time': Timestamp.now(),
        'comment': _lastWords,
        'language': 1,
        'split': 1,
      });

      setState(() {
        _lastWords = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    _startTimer();
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(minutes: 3),
      pauseFor: Duration(seconds: 5),
    );

    setState(() {});
  }

  void _stopListening() async {
    _timer.cancel();
    await _speechToText.stop();
    setState(() {
      _timerSeconds = 0;
      _sendMessage();
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      _sendMessage();
      _timerSeconds = 0;
      _timer.cancel();
    }
  }

  void _startTimer() {
    _timerSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
        if (_timerSeconds >= 180) {
          _stopListening();
        }
      });
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recognized words:',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              _speechToText.isListening
                  ? '$_lastWords'
                  : _speechEnabled
                  ? 'Tap to speak...'
                  : 'Speech not available',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTimer(_timerSeconds),
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              IconButton(
                onPressed:
                _speechToText.isNotListening ? _startListening : _stopListening,
                tooltip: '듣기',
                icon: Icon(
                  _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
