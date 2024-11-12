import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../pages/dashboard.dart';
import '../pages/movies.dart';
import '../pages/profile.dart';
import '../pages/shows.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        body: <Widget>[Dashboard(), Shows(), Movies(), Profile()][_selectedIndex],
        bottomNavBar: PlatformNavBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.movie_outlined), activeIcon: Icon(Icons.movie), label: 'Shows'),
            BottomNavigationBarItem(icon: Icon(Icons.local_movies_outlined), activeIcon: Icon(Icons.local_movies), label: 'Movies'),
            BottomNavigationBarItem(icon: Icon(Icons.person_2_rounded), label: 'Me'),
          ],
          currentIndex: _selectedIndex,
          itemChanged: _onItemTapped,
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
