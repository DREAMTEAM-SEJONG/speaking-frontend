import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mal_hae_bol_le/talking/talking_button.dart';
import 'package:uuid/uuid.dart';

class Talking extends StatefulWidget {
  const Talking({super.key});

  @override
  State<Talking> createState() => _TalkingState();
}

class _TalkingState extends State<Talking> {
  final Uuid _uuid = Uuid();

  Future<void> _newRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('chat').doc(user.uid);
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
        .collection('chat')
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
              'Please log in to view the chat.',
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


        return Scaffold(
          backgroundColor: Colors.grey[800],
          body: ListView(
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
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
                            child: DottedBorder(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: MediaQuery.sizeOf(context).width/10*4),
                              borderType: BorderType.RRect,
                              color: Colors.white,
                              dashPattern: [10,5],
                              radius: Radius.circular(20),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TalkingButton(
                        onUpdate: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
