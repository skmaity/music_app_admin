import 'dart:convert';
import 'package:equatable/equatable.dart';

class MySongs extends Equatable {
  final int songid;
  final String title;
  final String songurl;
  final String coverurl;
  final String artist;
  final int isquickpick;

  const MySongs({
    required this.songid,
    required this.title,
    required this.songurl,
    required this.coverurl,
    required this.artist,
    required this.isquickpick,
  });

  MySongs copyWith({
    int? songid,
    String? title,
    String? songurl,
    String? coverurl,
    String? artist,
    int? isquickpick,
  }) => 
      MySongs(
        songid: songid ?? this.songid,
        title: title ?? this.title,
        songurl: songurl ?? this.songurl,
        coverurl: coverurl ?? this.coverurl,
        artist: artist ?? this.artist,
        isquickpick: isquickpick ?? this.isquickpick,
      );

  factory MySongs.fromRawJson(Map<String, dynamic> map) => MySongs.fromJson(map);

  String toRawJson() => json.encode(toJson());

  /// Parsed defensively: the API returns numbers as strings on some endpoints
  /// (`get_artist_details.php` fetches songs through a prepared statement,
  /// where PDO stringifies), and a missing key used to crash here.
  factory MySongs.fromJson(Map<String, dynamic> json) => MySongs(
    songid: int.tryParse('${json["songid"]}') ?? 0,
    title: '${json["title"] ?? ''}',
    songurl: '${json["songurl"] ?? ''}',
    coverurl: '${json["coverurl"] ?? ''}',
    artist: '${json["artist"] ?? ''}',
    isquickpick: int.tryParse('${json["isquickpick"]}') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "songid": songid,
    "title": title,
    "songurl": songurl,
    "coverurl": coverurl,
    "artist": artist,
    "isquickpick": isquickpick,
  };

  @override
  List<Object?> get props => [songid, title, songurl, coverurl, artist, isquickpick];
}
