// Import the test package and Counter class

import 'package:nyaashows/data/data_manager.dart';
import 'package:test/test.dart';

void main() {
  test('Real-Debrid testing', () async {
    DataManager.traktData.showProgress('grey-s-anatomy');
  });
}
