import 'package:flutter/widgets.dart';

import '../search/search.dart';

class Movies extends StatelessWidget {
  const Movies({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Center(child: Search()), Text('Movies')],
    );
  }
}
