class Ids {
  String? trakt;
  String? tvdb;
  String? imdb;
  String? tmdb;

  Ids({
    required this.trakt,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"].toString(),
        tvdb: json["tvdb"].toString(),
        imdb: json["imdb"],
        tmdb: json["tmdb"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
      };
}
