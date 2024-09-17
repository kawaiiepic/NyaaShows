import 'dart:convert';

TvdbArtwork tvdbArtworkFromJson(String str) =>
    TvdbArtwork.fromJson(json.decode(str));

String tvdbArtworkToJson(TvdbArtwork data) => json.encode(data.toJson());

class TvdbArtwork {
  String status;
  Data data;

  TvdbArtwork({
    required this.status,
    required this.data,
  });

  factory TvdbArtwork.fromJson(Map<String, dynamic> json) => TvdbArtwork(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  int id;
  String name;
  String slug;
  String image;
  List<String> nameTranslations;
  List<String> overviewTranslations;
  List<dynamic> aliases;
  DateTime firstAired;
  DateTime lastAired;
  String nextAired;
  int score;
  DataStatus status;
  String originalCountry;
  String originalLanguage;
  int defaultSeasonType;
  bool isOrderRandomized;
  DateTime lastUpdated;
  int averageRuntime;
  dynamic episodes;
  String overview;
  String year;
  List<Artwork> artworks;
  dynamic companies;
  dynamic genres;
  dynamic trailers;
  dynamic lists;
  dynamic remoteIds;
  dynamic characters;
  AirsDays airsDays;
  dynamic airsTime;
  dynamic seasons;
  dynamic tags;
  dynamic contentRatings;

  Data({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.nameTranslations,
    required this.overviewTranslations,
    required this.aliases,
    required this.firstAired,
    required this.lastAired,
    required this.nextAired,
    required this.score,
    required this.status,
    required this.originalCountry,
    required this.originalLanguage,
    required this.defaultSeasonType,
    required this.isOrderRandomized,
    required this.lastUpdated,
    required this.averageRuntime,
    required this.episodes,
    required this.overview,
    required this.year,
    required this.artworks,
    required this.companies,
    required this.genres,
    required this.trailers,
    required this.lists,
    required this.remoteIds,
    required this.characters,
    required this.airsDays,
    required this.airsTime,
    required this.seasons,
    required this.tags,
    required this.contentRatings,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        nameTranslations:
            List<String>.from(json["nameTranslations"].map((x) => x)),
        overviewTranslations:
            List<String>.from(json["overviewTranslations"].map((x) => x)),
        aliases: List<dynamic>.from(json["aliases"].map((x) => x)),
        firstAired: DateTime.parse(json["firstAired"]),
        lastAired: DateTime.parse(json["lastAired"]),
        nextAired: json["nextAired"],
        score: json["score"],
        status: DataStatus.fromJson(json["status"]),
        originalCountry: json["originalCountry"],
        originalLanguage: json["originalLanguage"],
        defaultSeasonType: json["defaultSeasonType"],
        isOrderRandomized: json["isOrderRandomized"],
        lastUpdated: DateTime.parse(json["lastUpdated"]),
        averageRuntime: json["averageRuntime"],
        episodes: json["episodes"],
        overview: json["overview"],
        year: json["year"],
        artworks: List<Artwork>.from(
            json["artworks"].map((x) => Artwork.fromJson(x))),
        companies: json["companies"],
        genres: json["genres"],
        trailers: json["trailers"],
        lists: json["lists"],
        remoteIds: json["remoteIds"],
        characters: json["characters"],
        airsDays: AirsDays.fromJson(json["airsDays"]),
        airsTime: json["airsTime"],
        seasons: json["seasons"],
        tags: json["tags"],
        contentRatings: json["contentRatings"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
        "nameTranslations": List<dynamic>.from(nameTranslations.map((x) => x)),
        "overviewTranslations":
            List<dynamic>.from(overviewTranslations.map((x) => x)),
        "aliases": List<dynamic>.from(aliases.map((x) => x)),
        "firstAired":
            "${firstAired.year.toString().padLeft(4, '0')}-${firstAired.month.toString().padLeft(2, '0')}-${firstAired.day.toString().padLeft(2, '0')}",
        "lastAired":
            "${lastAired.year.toString().padLeft(4, '0')}-${lastAired.month.toString().padLeft(2, '0')}-${lastAired.day.toString().padLeft(2, '0')}",
        "nextAired": nextAired,
        "score": score,
        "status": status.toJson(),
        "originalCountry": originalCountry,
        "originalLanguage": originalLanguage,
        "defaultSeasonType": defaultSeasonType,
        "isOrderRandomized": isOrderRandomized,
        "lastUpdated": lastUpdated.toIso8601String(),
        "averageRuntime": averageRuntime,
        "episodes": episodes,
        "overview": overview,
        "year": year,
        "artworks": List<dynamic>.from(artworks.map((x) => x.toJson())),
        "companies": companies,
        "genres": genres,
        "trailers": trailers,
        "lists": lists,
        "remoteIds": remoteIds,
        "characters": characters,
        "airsDays": airsDays.toJson(),
        "airsTime": airsTime,
        "seasons": seasons,
        "tags": tags,
        "contentRatings": contentRatings,
      };
}

class AirsDays {
  bool sunday;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;

  AirsDays({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory AirsDays.fromJson(Map<String, dynamic> json) => AirsDays(
        sunday: json["sunday"],
        monday: json["monday"],
        tuesday: json["tuesday"],
        wednesday: json["wednesday"],
        thursday: json["thursday"],
        friday: json["friday"],
        saturday: json["saturday"],
      );

  Map<String, dynamic> toJson() => {
        "sunday": sunday,
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thursday": thursday,
        "friday": friday,
        "saturday": saturday,
      };
}

class Artwork {
  int id;
  String image;
  String thumbnail;
  String? language;
  int type;
  int score;
  int width;
  int height;
  bool includesText;
  int thumbnailWidth;
  int thumbnailHeight;
  int updatedAt;
  ArtworkStatus status;
  dynamic tagOptions;

  Artwork({
    required this.id,
    required this.image,
    required this.thumbnail,
    required this.language,
    required this.type,
    required this.score,
    required this.width,
    required this.height,
    required this.includesText,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.updatedAt,
    required this.status,
    required this.tagOptions,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
        id: json["id"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        language: json["language"],
        type: json["type"],
        score: json["score"],
        width: json["width"],
        height: json["height"],
        includesText: json["includesText"],
        thumbnailWidth: json["thumbnailWidth"],
        thumbnailHeight: json["thumbnailHeight"],
        updatedAt: json["updatedAt"],
        status: ArtworkStatus.fromJson(json["status"]),
        tagOptions: json["tagOptions"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "thumbnail": thumbnail,
        "language": language,
        "type": type,
        "score": score,
        "width": width,
        "height": height,
        "includesText": includesText,
        "thumbnailWidth": thumbnailWidth,
        "thumbnailHeight": thumbnailHeight,
        "updatedAt": updatedAt,
        "status": status.toJson(),
        "tagOptions": tagOptions,
      };
}

class ArtworkStatus {
  int id;
  dynamic name;

  ArtworkStatus({
    required this.id,
    required this.name,
  });

  factory ArtworkStatus.fromJson(Map<String, dynamic> json) => ArtworkStatus(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class DataStatus {
  int id;
  String name;
  String recordType;
  bool keepUpdated;

  DataStatus({
    required this.id,
    required this.name,
    required this.recordType,
    required this.keepUpdated,
  });

  factory DataStatus.fromJson(Map<String, dynamic> json) => DataStatus(
        id: json["id"],
        name: json["name"],
        recordType: json["recordType"],
        keepUpdated: json["keepUpdated"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "recordType": recordType,
        "keepUpdated": keepUpdated,
      };
}
