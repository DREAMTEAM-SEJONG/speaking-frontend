import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble(this.message, this.split, {super.key});

  final String message;
  final int split;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final FlutterTts tts = FlutterTts();
  static _ChatBubbleState? _currentSpeakingBubble;

  @override
  void initState() {
    super.initState();
    tts.setVolume(1.0);
    tts.setSpeechRate(0.5);
    tts.setLanguage("ko-KR");
    tts.setVoice({"name": "ko-kr-x-ism-local", "locale": "ko-KR"});

    // Automatically read the text if split is 2
    if (widget.split == 2) {
      _speakText(widget.message);
    }
  }

  @override
  void dispose() {
    // Stop speaking when this instance is disposed
    if (_currentSpeakingBubble == this) {
      tts.stop();
      _currentSpeakingBubble = null;
    }
    super.dispose();
  }

  void _speakText(String text) async {
    // Stop the previous speaking instance
    if (_currentSpeakingBubble != null && _currentSpeakingBubble != this) {
      await _currentSpeakingBubble!.tts.stop();
    }

    // Set the current speaking bubble to this instance
    _currentSpeakingBubble = this;
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
    TextEditingController(text: widget.message);

    return Row(
      mainAxisAlignment: widget.split == 1 || widget.split == 4
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        widget.split == 4
            ? DottedBorder(
          strokeWidth: 2,
          borderType: BorderType.RRect,
          color: Colors.grey,
          dashPattern: [8, 4],
          radius: Radius.circular(15),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(0),
                  bottomLeft: Radius.circular(12),
                )),
            width: MediaQuery.of(context).size.width / 2,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'say like this:',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  widget.message,
                  style: TextStyle(color: Colors.white),
                  maxLines: null, // 줄바꿈을 가능하게 합니다.
                  overflow:
                  TextOverflow.visible, // 텍스트가 넘칠 경우 보이도록 설정합니다.
                ),
              ],
            ),
          ),
        )
            : Container(
          decoration: BoxDecoration(
              color: widget.split == 1 ? Colors.grey : Colors.black26,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: widget.split == 1
                    ? Radius.circular(0)
                    : Radius.circular(12),
                bottomLeft: widget.split == 1
                    ? Radius.circular(12)
                    : Radius.circular(0),
              )),
          width: MediaQuery.of(context).size.width / 2,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message,
                style: TextStyle(
                    color:
                    widget.split == 1 ? Colors.black : Colors.white),
                maxLines: null, // 줄바꿈을 가능하게 합니다.
                overflow: TextOverflow.visible, // 텍스트가 넘칠 경우 보이도록 설정합니다.
              ),
              if (widget.split == 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _speakText(controller.text);
                      },
                      child: Container(
                        padding:
                        EdgeInsets.all(0), // 아이콘 주위의 여백을 조정할 수 있습니다.
                        child: Icon(
                          Icons.volume_up,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
