import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_app_admin/models/artist_model.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

/// Raised when the API answers with `success: false`. Carries the server's own
/// `message`, so a bloc can put `'$e'` straight into a toast.
class ArtistFailure implements Exception {
  final String message;
  const ArtistFailure(this.message);

  @override
  String toString() => message;
}

/// Every artist call, in one place — six artist endpoints shared across two
/// blocs, most of them multipart, so the blocs stay pure state machines.
///
/// All of these PHP endpoints read `$_POST`, so writes go out as [FormData]:
/// multipart populates `$_POST`, a JSON body would arrive empty.
class ArtistRepo {
  ArtistRepo({Dio? dio}) : _dio = dio ?? authDio();

  final Dio _dio;

  /// `get_all_artists.php` → `{success, message, data: [...]}`
  Future<List<Artist>> getArtists() async {
    final body = _unwrap((await _dio.get(getAllArtistsUrl)).data);
    final rows = body['data'] as List? ?? const [];
    return rows.map((e) => Artist.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// `get_artist_details.php` answers with `artist` and `songs` at the top
  /// level rather than under `data`, and the songs use the same shape as
  /// `get_all_songs.php`.
  Future<(Artist, List<MySongs>)> getArtistDetails(int artistId) async {
    final body = _unwrap(
      (await _dio.get(getArtistDetailsUrl, queryParameters: {'artist_id': artistId})).data,
    );
    final rows = body['songs'] as List? ?? const [];
    final songs = rows.map((e) => MySongs.fromJson(Map<String, dynamic>.from(e))).toList();
    final artist = Artist.fromJson(Map<String, dynamic>.from(body['artist']))
        .copyWith(totalSongs: songs.length);
    return (artist, songs);
  }

  /// A duplicate name comes back as `success: false` ("An artist with this
  /// name already exists."), so `_unwrap` throws [ArtistFailure] and the bloc
  /// surfaces it as a failure toast — same as any other rejected write.
  Future<String> createArtist({
    required String name,
    required String bio,
    PlatformFile? image,
  }) =>
      _post(createArtistUrl, {
        'name': name,
        'bio': bio,
        ..._imageField(image),
      });

  Future<String> updateArtist({
    required int artistId,
    required String name,
    required String bio,
    PlatformFile? image,
  }) =>
      _post(updateArtistUrl, {
        'artist_id': artistId,
        'name': name,
        'bio': bio,
        ..._imageField(image),
      });

  /// Songs are never deleted — `delete_songs: 0` makes the endpoint null out
  /// `songs.artist_id` instead.
  Future<String> deleteArtist(int artistId) =>
      _post(deleteArtistUrl, {'artist_id': artistId, 'delete_songs': 0});

  /// Uploads a song and credits it to the artist in one call.
  Future<String> addSongToArtist({
    required int artistId,
    required String title,
    required PlatformFile cover,
    required PlatformFile audio,
  }) =>
      _post(addSongToArtistUrl, {
        'artist_id': artistId,
        'title': title,
        'coverfile': MultipartFile.fromBytes(cover.bytes!, filename: cover.name),
        'songfile': MultipartFile.fromBytes(audio.bytes!, filename: audio.name),
      });

  /// Credits an existing song to [artistId], or drops its credit when
  /// [artistId] is null.
  ///
  /// There is no dedicated link endpoint — `admin_update_song.php` owns
  /// `songs.artist_id`, and it resolves the id from whichever of `artist_id` /
  /// `artist` it is given. It also rejects a request that carries neither, so
  /// unlinking is done by passing the "Unknown Artist" sentinel: no row matches
  /// it, the lookup comes back empty and the column is written as NULL.
  Future<String> setSongArtist({required MySongs song, int? artistId}) => _post(
        adminUpdateSongUrl,
        {
          'songid': song.songid,
          'title': song.title,
          if (artistId != null) 'artist_id': artistId else 'artist': unknownArtist,
        },
      );

  Future<List<MySongs>> getAllSongs() async {
    final body = _unwrap((await _dio.get(adminGetAllSongsUrl)).data);
    final rows = body['data'] as List? ?? const [];
    return rows.map((e) => MySongs.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// The endpoints take either an uploaded file or a URL string; we only ever
  /// send a file, and omit the field entirely when the admin picked nothing.
  Map<String, dynamic> _imageField(PlatformFile? image) => image?.bytes == null
      ? const {}
      : {'imagefile': MultipartFile.fromBytes(image!.bytes!, filename: image.name)};

  Future<String> _post(String url, Map<String, dynamic> fields) async {
    final body = _unwrap((await _dio.post(url, data: FormData.fromMap(fields))).data);
    return '${body['message'] ?? 'Done.'}';
  }

  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is! Map) {
      throw const ArtistFailure('The server sent a response we could not read.');
    }
    final map = Map<String, dynamic>.from(body);
    if (map['success'] != true) {
      throw ArtistFailure('${map['message'] ?? 'The server rejected the request.'}');
    }
    return map;
  }
}

/// What `songs.artist` is set to when a song is removed from its artist.
const String unknownArtist = 'Unknown Artist';
