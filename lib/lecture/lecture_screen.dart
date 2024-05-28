import 'package:flutter/material.dart';
import 'package:mal_hae_bol_le/lecture/each_talking_lecture.dart';
import 'package:mal_hae_bol_le/lecture/record.dart';

//채팅 페이지
class LectureScreen extends StatefulWidget {
  final String roomNumber;

  const LectureScreen({super.key, required this.roomNumber});

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Lecture Translate'),
          backgroundColor: Colors.grey[900],
        ),
        body: Container(
          color: Colors.grey[800],
          child: Column(
            children: [
              Expanded(
                child: EachTalkingLecture(
                  roomNumber: widget.roomNumber,
                ),
              ),
              Record(
                roomNumber: widget.roomNumber,
              ),
            ],
          ),
        ));
  }
}
