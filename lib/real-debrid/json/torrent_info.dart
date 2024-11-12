// To parse this JSON data, do
//
//     final torrentInfo = torrentInfoFromJson(jsonString);

import 'dart:convert';

TorrentInfo torrentInfoFromJson(String str) => TorrentInfo.fromJson(json.decode(str));

String torrentInfoToJson(TorrentInfo data) => json.encode(data.toJson());

class TorrentInfo {
  String id;
  String filename;
  String originalFilename;
  String hash;
  int bytes;
  int originalBytes;
  String host;
  int split;
  double progress;
  String status;
  String added;
  List<FileElement> files;
  List<String> links;
  String? ended;
  int? speed;
  int? seeders;

  TorrentInfo({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.hash,
    required this.bytes,
    required this.originalBytes,
    required this.host,
    required this.split,
    required this.progress,
    required this.status,
    required this.added,
    required this.files,
    required this.links,
    required this.ended,
    required this.speed,
    required this.seeders,
  });

  factory TorrentInfo.fromJson(Map<String, dynamic> json) => TorrentInfo(
        id: json["id"],
        filename: json["filename"],
        originalFilename: json["original_filename"],
        hash: json["hash"],
        bytes: json["bytes"],
        originalBytes: json["original_bytes"],
        host: json["host"],
        split: json["split"],
        progress: double.parse(json["progress"].toString()),
        status: json["status"],
        added: json["added"],
        files: List<FileElement>.from(json["files"].map((x) => FileElement.fromJson(x))),
        links: List<String>.from(json["links"].map((x) => x)),
        ended: json["ended"],
        speed: json["speed"],
        seeders: json["seeders"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "filename": filename,
        "original_filename": originalFilename,
        "hash": hash,
        "bytes": bytes,
        "original_bytes": originalBytes,
        "host": host,
        "split": split,
        "progress": progress,
        "status": status,
        "added": added,
        "files": List<dynamic>.from(files.map((x) => x.toJson())),
        "links": List<dynamic>.from(links.map((x) => x)),
        "ended": ended,
        "speed": speed,
        "seeders": seeders,
      };
}

class FileElement {
  int id;
  String path;
  int bytes;
  int selected;

  FileElement({
    required this.id,
    required this.path,
    required this.bytes,
    required this.selected,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        path: json["path"],
        bytes: json["bytes"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "path": path,
        "bytes": bytes,
        "selected": selected,
      };
}
