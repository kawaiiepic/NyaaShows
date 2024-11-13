import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../pages/calendar.dart';
import '../pages/dashboard.dart';
import '../pages/movies.dart';
import '../pages/profile.dart';
import '../pages/shows.dart';
import 'popup_menu.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return navigationRail();
  }

  Widget navigationRail() {
    return PlatformScaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      NavigationRail(
          labelType: NavigationRailLabelType.all,
          groupAlignment: 0,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: [
            NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_filled), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(Icons.movie_outlined), selectedIcon: Icon(Icons.movie), label: Text('TV Shows')),
            NavigationRailDestination(icon: Icon(Icons.local_movies_outlined), selectedIcon: Icon(Icons.local_movies), label: Text('Movies')),
            NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Calendar')),
            NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: Text('Me')),
          ],
          leading: PopupMenu(),
          selectedIndex: _selectedIndex),
      const VerticalDivider(thickness: 1, width: 1),
      page()
    ]));
  }

  Widget page() {
    return [Dashboard(), Shows(), Movies(), Calendar(), Profile()][_selectedIndex];
  }
}
