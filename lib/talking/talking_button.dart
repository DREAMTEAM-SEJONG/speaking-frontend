import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mal_hae_bol_le/talking/chat_screen.dart';

class TalkingButton extends StatelessWidget {
  final Function onUpdate;

  TalkingButton({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in to view the chat.'));
    }

    final userDoc = FirebaseFirestore.instance.collection('chat').doc(user.uid);

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

        return GridView.builder(
          itemCount: chatDocs.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 9 / 10,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
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
  return TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(roomNumber: roomNumber),
        ),
      );
    },
    child: Container(
      width: 170,
      child: Column(
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Image.network(
                        'https://static.vecteezy.com/system/resources/previews/005/337/802/non_2x/icon-symbol-chat-outline-illustration-free-vector.jpg',
                        width: MediaQuery.of(context).size.width / 5 * 2,
                        height: MediaQuery.of(context).size.height / 5 * 1,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      child: Opacity(
                        opacity: 0.6,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5 * 2,
                          height: MediaQuery.of(context).size.height / 5 * 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white10,
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 5 * 2,
                        height: MediaQuery.of(context).size.height / 5 * 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 120,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            DocumentReference roomDoc = FirebaseFirestore.instance
                                .collection('chat')
                                .doc(user.uid)
                                .collection('rooms')
                                .doc(roomId);
                            await roomDoc.delete();
                            onDelete(); // Update state after deletion
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
              formatDate(time.toDate().toString()),

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
