import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mal_hae_bol_le/home/recommend_lecture_button.dart';
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
                    //todo 최근 활동 동아리
                    'Recommend',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  trailing:PopupMenuButton<MenuType>(
                    icon: Icon(Icons.menu),
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
                LectureRecommendButton(_selection),
                Container(color: Colors.grey.shade800,width: context.mediaQuerySize.width,height: context.mediaQuerySize.height,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
