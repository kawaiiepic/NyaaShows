class Ids {
  String? trakt;
  String? slug;
  String? tvdb;
  String? imdb;
  String? tmdb;
  String? tvrage;

  Ids({
    required this.trakt,
    required this.slug,
    required this.tvdb,
    required this.imdb,
    required this.tmdb,
    required this.tvrage
  });

  factory Ids.fromJson(Map<String, dynamic> json) => Ids(
        trakt: json["trakt"].toString(),
        slug: json["slug"],
        tvdb: json["tvdb"].toString(),
        imdb: json["imdb"],
        tmdb: json["tmdb"].toString(),
        tvrage: json["tvrage"],
      );

  Map<String, dynamic> toJson() => {
        "trakt": trakt,
        "slug": slug,
        "tvdb": tvdb,
        "imdb": imdb,
        "tmdb": tmdb,
        "tvrage": tvrage,
      };
}
