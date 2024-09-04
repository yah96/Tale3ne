import 'package:flutter/material.dart';
import 'package:tale3ne/pages/chat/Chats_page.dart';
import 'package:tale3ne/pages/Map/LocationMap.dart';
import 'package:tale3ne/pages/Main/Home_page.dart';

class HomeTabBar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String ID;

  HomeTabBar({
    required this.firstName,
    required this.lastName,
    required this.ID,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(

        body: TabBarView(
          children: [
            HomePage(firstName: firstName, lastName: lastName, ID: ID),
            ChatsPage(id :ID , name : firstName + " " + lastName),
            LocationMap(userId: ID,userName: firstName + " " + lastName),
          ],
        ),
      ),
    );
  }
}
