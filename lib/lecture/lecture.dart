import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mal_hae_bol_le/lecture/lecture_button.dart';
import 'package:uuid/uuid.dart';

//강의요약
class Lecture extends StatefulWidget {
  const Lecture({super.key});

  @override
  State<Lecture> createState() => _LectureState();
}

class _LectureState extends State<Lecture> {

  final Uuid _uuid = Uuid();

  Future<void> _newRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('lecture').doc(user.uid);
      CollectionReference roomCollection = userDoc.collection('rooms');

      final roomId = _uuid.v4();

      await roomCollection.doc(roomId).set({
        'room_id': roomId,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<int> _getRoomCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0;
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('lecture')
        .doc(user.uid)
        .collection('rooms')
        .get();

    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Container(
        color: Colors.grey.shade900,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: Colors.grey.shade800,
            ),
            child: Center(
                child: Text(
                  'Please log in to view the lecture.',
                  style: TextStyle(color: Colors.white),
                ))),
      );
    }
    return FutureBuilder<int>(
      future: _getRoomCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }


        return ListView(
          physics: ClampingScrollPhysics(),
          children: [
            Container(
              color: Colors.grey[900],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  color: Colors.grey.shade800,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Histories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          try {
                            await _newRoom();
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error creating room: $e')),
                            );
                          }
                        },
                        color: Colors.white,
                      ),
                    ),
                    LectureButton(
                      onUpdate: () {
                        setState(() {});
                      },
                    ),
                    Container(
                      color: Colors.grey.shade800,
                      width: context.mediaQuerySize.width,
                      height: context.mediaQuerySize.height,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
