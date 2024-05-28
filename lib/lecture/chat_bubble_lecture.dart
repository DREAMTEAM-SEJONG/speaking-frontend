import 'package:flutter/material.dart';

class ChatBubbleLecture extends StatelessWidget {
  const ChatBubbleLecture(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12)
          ),
          width: MediaQuery.of(context).size.width/10*9,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ],
    );
  }
}
