import 'package:equatable/equatable.dart';
import 'package:music_app_admin/url_admin.dart';

/// One row of the `artists` table.
///
/// A song belongs to at most one artist (`songs.artist_id`), so `totalSongs`
/// is the count the API reports for that foreign key plus any song whose free
/// text `artist` happens to match the name.
class Artist extends Equatable {
  final int artistId;
  final String name;
  final String? bio;
  final String? imageurl;
  final int totalSongs;

  const Artist({
    required this.artistId,
    required this.name,
    this.bio,
    this.imageurl,
    this.totalSongs = 0,
  });

  /// `imageurl` holds either a relative upload path (`uploads/artists/…`) or an
  /// absolute URL the admin pasted in. Only the former needs [baseUrl].
  String? get imageLink {
    final url = imageurl;
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : '$baseUrl$url';
  }

  /// Parsed defensively: `bio` and `imageurl` are genuinely nullable, and the
  /// API hands numbers back as strings on some rows.
  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        artistId: int.tryParse('${json['artist_id']}') ?? 0,
        name: '${json['name'] ?? ''}',
        bio: json['bio']?.toString(),
        imageurl: json['imageurl']?.toString(),
        totalSongs: int.tryParse('${json['total_songs']}') ?? 0,
      );

  Artist copyWith({int? totalSongs}) => Artist(
        artistId: artistId,
        name: name,
        bio: bio,
        imageurl: imageurl,
        totalSongs: totalSongs ?? this.totalSongs,
      );

  @override
  List<Object?> get props => [artistId, name, bio, imageurl, totalSongs];
}
