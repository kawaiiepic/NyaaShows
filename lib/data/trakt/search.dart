class Search {
  String type;
  double score;
  Movie? movie;
  Movie? show;
  Episode? episode;
  Person? person;
  ListClass? list;

  Search({
    required this.type,
    required this.score,
    this.movie,
    this.show,
    this.episode,
    this.person,
    this.list,
  });
}

class Episode {
  int season;
  int number;
  String title;
  EpisodeIds ids;

  Episode({
    required this.season,
    required this.number,
    required this.title,
    required this.ids,
  });
}

class EpisodeIds {
  int trakt;
  int? tvdb;
  String? imdb;
  int tmdb;
  String? slug;

  EpisodeIds({
    required this.trakt,
    this.tvdb,
    required this.imdb,
    required this.tmdb,
    this.slug,
  });
}

class ListClass {
  String name;
  String description;
  String privacy;
  String shareLink;
  String type;
  bool displayNumbers;
  bool allowComments;
  String sortBy;
  String sortHow;
  DateTime createdAt;
  DateTime updatedAt;
  int itemCount;
  int commentCount;
  int likes;
  ListIds ids;
  User user;

  ListClass({
    required this.name,
    required this.description,
    required this.privacy,
    required this.shareLink,
    required this.type,
    required this.displayNumbers,
    required this.allowComments,
    required this.sortBy,
    required this.sortHow,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCount,
    required this.commentCount,
    required this.likes,
    required this.ids,
    required this.user,
  });
}

class ListIds {
  int trakt;
  String slug;

  ListIds({
    required this.trakt,
    required this.slug,
  });
}

class User {
  String username;
  bool private;
  String name;
  bool vip;
  bool vipEp;
  UserIds ids;

  User({
    required this.username,
    required this.private,
    required this.name,
    required this.vip,
    required this.vipEp,
    required this.ids,
  });
}

class UserIds {
  String slug;

  UserIds({
    required this.slug,
  });
}

class Movie {
  String title;
  int year;
  EpisodeIds ids;

  Movie({
    required this.title,
    required this.year,
    required this.ids,
  });
}

class Person {
  String name;
  EpisodeIds ids;

  Person({
    required this.name,
    required this.ids,
  });
}
