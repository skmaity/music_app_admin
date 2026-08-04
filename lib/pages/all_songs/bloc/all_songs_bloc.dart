import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart' as d;
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

part 'all_songs_event.dart';
part 'all_songs_state.dart';

class AllSongsBloc extends Bloc<AllSongsEvent, AllSongsState> {
  final d.Dio _dio = authDio();

  AllSongsBloc() : super(const AllSongsState()) {
    on<LoadAllSongs>(_onLoadAllSongs);
    on<FilterSongs>(_onFilterSongs);
    on<UpdateSong>(_onUpdateSong);
    on<DeleteSong>(_onDeleteSong);
    on<SongOperationCompleted>(_onSongOperationCompleted);
  }

  Future<void> _onLoadAllSongs(LoadAllSongs event, Emitter<AllSongsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _dio.get(adminGetAllSongsUrl);
      final data = response.data['data'] as List?;
      if (data != null) {
        final songs = data.map((e) => MySongs.fromJson(e)).toList();
        emit(state.copyWith(songs: songs, isLoading: false));
      } else {
        emit(state.copyWith(
          isLoading: false,
          toastMessage: () => 'Failed to parse songs',
          toastSuccess: () => false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: () => 'Failed to fetch songs: $e',
        toastSuccess: () => false,
      ));
    }
  }

  void _onFilterSongs(FilterSongs event, Emitter<AllSongsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onUpdateSong(UpdateSong event, Emitter<AllSongsState> emit) async {
    emit(state.copyWith(busyId: () => event.song.songid));
    try {
      final response = await _dio.post(
        adminUpdateSongUrl,
        data: d.FormData.fromMap({
          'songid': event.song.songid,
          'title': event.title,
          'artist': event.artist,
          if (event.cover?.bytes != null)
            'coverfile': d.MultipartFile.fromBytes(event.cover!.bytes!, filename: event.cover!.name),
          if (event.audio?.bytes != null)
            'songfile': d.MultipartFile.fromBytes(event.audio!.bytes!, filename: event.audio!.name),
        }),
        options: d.Options(contentType: 'multipart/form-data'),
      );

      final success = response.data['success'] == true;
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => '${response.data['message']}',
        toastSuccess: () => success,
      ));
      
      if (success) {
        add(LoadAllSongs());
      }
    } catch (e) {
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => 'Update failed: $e',
        toastSuccess: () => false,
      ));
    }
  }

  Future<void> _onDeleteSong(DeleteSong event, Emitter<AllSongsState> emit) async {
    emit(state.copyWith(busyId: () => event.song.songid));
    try {
      final response = await _dio.post(adminDeleteSongUrl, data: {'songid': event.song.songid});
      final success = response.data['success'] == true;
      
      if (success) {
        final updatedList = List<MySongs>.from(state.songs)..removeWhere((s) => s.songid == event.song.songid);
        emit(state.copyWith(
          busyId: () => null,
          songs: updatedList,
          toastMessage: () => '${response.data['message']}',
          toastSuccess: () => success,
        ));
      } else {
        emit(state.copyWith(
          busyId: () => null,
          toastMessage: () => '${response.data['message']}',
          toastSuccess: () => success,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => 'Delete failed: $e',
        toastSuccess: () => false,
      ));
    }
  }

  void _onSongOperationCompleted(SongOperationCompleted event, Emitter<AllSongsState> emit) {
    emit(state.copyWith(
      toastMessage: () => null,
      toastSuccess: () => null,
    ));
  }
}
