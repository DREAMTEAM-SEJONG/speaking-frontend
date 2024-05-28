import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewTalking extends StatefulWidget {
  final String roomNumber;

  const NewTalking({super.key, required this.roomNumber});

  @override
  State<NewTalking> createState() => _NewTalkingState();
}

class _NewTalkingState extends State<NewTalking> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Future<void> _sendMessage() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (_lastWords != '' && user != null) {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('chat').doc(user.uid);
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

      // 메시지를 보낸 후 _lastWords를 초기화
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
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
    );

    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {_sendMessage();});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    // 음성 인식이 완료되었는지 확인
    if (result.finalResult) {
      _sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Column(children: [
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
            tooltip: '듣기',
            icon: Icon(
              _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
              size: 30,
              color: Colors.white,
            ),
          )
        ]),
      ]),
    );
  }
}
