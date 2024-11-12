import 'shows/extended_show.dart';
import 'shows/show.dart';
import 'shows/show_watched_progress.dart';
import 'shows/watched_progress.dart';

class CombinedShow {
  WatchedProgress watchedProgress;
  Show show;

  CombinedShow({required this.show, required this.watchedProgress});
}
