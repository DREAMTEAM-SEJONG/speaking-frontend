import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mal_hae_bol_le/home/home.dart';
import 'package:mal_hae_bol_le/lecture/lecture_screen.dart';
import 'package:mal_hae_bol_le/login/sign_in.dart';

class LectureButton extends StatelessWidget {
  final Function onUpdate;
  LectureButton({super.key,required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in to view the lecture.'));
    }
    final userDoc = FirebaseFirestore.instance.collection('lecture').doc(user.uid);
    return StreamBuilder(
      stream: userDoc.collection('rooms').orderBy('createdAt',descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages yet.'));
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            final roomId = chatDocs[index].id;
            final roomNumber = chatDocs[index]['room_id'];
            final time = chatDocs[index]['createdAt'];
            return CardButton(
              context: context,
              roomId: roomId,
              roomNumber: roomNumber,
              time: time,
              onDelete: onUpdate,
            );
          },
        );
      },
    );
  }
}
Widget CardButton({
  required BuildContext context,
  required String roomId,
  required String roomNumber,
  required Timestamp time,
  required Function onDelete,
}) {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDateString = DateFormat('MM/dd hh:mm').format(dateTime);
    return formattedDateString;
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LectureScreen(roomNumber: roomNumber),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.black26, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/005/337/802/non_2x/icon-symbol-chat-outline-illustration-free-vector.jpg'),
          ),
        ),
        title: Text(
          'Room',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          formatDate(time.toDate().toString()),
          style: TextStyle(
            color: Colors.grey[400],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              DocumentReference roomDoc = FirebaseFirestore.instance
                  .collection('lecture')
                  .doc(user.uid)
                  .collection('rooms')
                  .doc(roomId);
              await roomDoc.delete();
              onDelete(); // Update state after deletion
            }
          },
        ),
      ),
    ),
  );
}
