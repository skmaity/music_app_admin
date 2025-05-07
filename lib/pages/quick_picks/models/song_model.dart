// To parse this JSON data, do
//
//     final song = songFromJson(jsonString);

import 'dart:convert';

Song songFromJson(String str) => Song.fromJson(json.decode(str));

String songToJson(Song data) => json.encode(data.toJson());

class Song {
    String? title;
    String? songid;
    String? cover;
    String? song;
    String? artist;

    Song({
        this.title,
        this.songid,
        this.cover,
        this.song,
        this.artist,
    });

    Song copyWith({
        String? title,
        String? songid,
        String? cover,
        String? song,
        String? artist,
    }) => 
        Song(
            title: title ?? this.title,
            songid: songid ?? this.songid,
            cover: cover ?? this.cover,
            song: song ?? this.song,
            artist: artist ?? this.artist,
        );

    factory Song.fromJson(Map<String, dynamic> json) => Song(
        title: json["title"],
        songid: json["songid"],
        cover: json["cover"],
        song: json["song"],
        artist: json["artist"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "songid": songid,
        "cover": cover,
        "song": song,
        "artist": artist,
    };
}
