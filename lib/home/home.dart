import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mal_hae_bol_le/home/home_button_page.dart';
import 'package:mal_hae_bol_le/home/home_recommend_button.dart';
import 'package:mal_hae_bol_le/lecture/lecture_button.dart';

enum MenuType { easy, normal, hard }

extension ParseToString on MenuType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class LectureRecommend extends StatefulWidget {
  const LectureRecommend({super.key});

  @override
  State<LectureRecommend> createState() => _LectureRecommendState();
}

class _LectureRecommendState extends State<LectureRecommend> {
  @override
  late MenuType _selection = MenuType.easy;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Recommend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                trailing: PopupMenuButton<MenuType>(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onSelected: (MenuType result) {
                    setState(() {
                      _selection = result;
                    });
                  },
                  itemBuilder: (BuildContext context) => MenuType.values
                      .map((value) => PopupMenuItem(
                            value: value,
                            child: Text(value.toShortString()),
                          ))
                      .toList(),
                ),
              ),

              HomeRecommendButton(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'User-selected difficulty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              LectureButtonPage(_selection),
            ],
          ),
        ),
      ),
    );
  }
}
