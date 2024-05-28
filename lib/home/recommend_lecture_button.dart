import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mal_hae_bol_le/talking/chat_screen.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../lecture/lecture.dart';
import '../main.dart';
import 'home.dart';

class LectureRecommendButton extends StatelessWidget {
  LectureRecommendButton(this.level, {super.key});

  late MenuType level;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('study').snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs.where((doc) {
          return doc['level'] == level.index + 1;
        }).toList();

        return GridView.count(
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 9 / 10,
            children: List.generate(chatDocs.length,
                    (index) => CardButton(context, index, chatDocs)));
      },
    );
  }
}

Widget CardButton(BuildContext context, int index, List<DocumentSnapshot> chatDocs) {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(chatDocs[index]['link']));

  return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Scaffold(
                body: WebViewWidget(
                  controller: controller,
                ),
              )),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 5 * 2,
        child: Column(
          children: [
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  child: Stack(children: [
                    Positioned(
                      child: Image.network(
                        chatDocs[index]['image'],
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
                                )),
                          ),
                        )),
                    Positioned(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5 * 2,
                          height: MediaQuery.of(context).size.height / 5 * 1,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.1)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                        )),
                    Positioned(
                        top: 140,
                        left: 10,
                        child: Text(
                          chatDocs[index]['level'] == 1
                              ? '초급'
                              : chatDocs[index]['level'] == 2
                              ? '중급'
                              : chatDocs[index]['level'] == 3
                              ? '고급'
                              : '기타',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        )),
                  ]),
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
                Container(
                  width: MediaQuery.of(context).size.width / 3 * 1,
                  child: Text(
                    chatDocs[index]['title'],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
}
