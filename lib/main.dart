import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mal_hae_bol_le/home/home.dart';
import 'package:mal_hae_bol_le/lecture/lecture.dart';
import 'package:mal_hae_bol_le/login/sign_in.dart';
import 'package:mal_hae_bol_le/talking/talking.dart';

import 'login/profile.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  bool isScrolled = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => user == null ? SignIn() : Profile()),
                      );
                    },
                    icon: Icon(Icons.account_box_rounded),
                    color: Colors.white,
                  ),
                ],
                leading: Container(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/logo.png')
                ),
                title: const Text(
                  '말해볼래',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.grey[900],
                bottom: const TabBar(
                  isScrollable: true,
                  indicatorWeight: 2.0,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  // labelPadding: EdgeInsets.all(6),
                  padding: EdgeInsets.all(3),
                  tabs: [
                    Text(
                      'Home',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Talking',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Lecture',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [LectureRecommend(), Talking(), Lecture()],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
