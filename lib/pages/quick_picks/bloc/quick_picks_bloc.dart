import 'package:dio/dio.dart' as d;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

part 'quick_picks_event.dart';
part 'quick_picks_state.dart';

/// Drives the two-column Quick Picks screen: the curated picks on the left, the
/// whole library on the right, and the add/remove toggle between them. Both
/// columns are re-fetched after a toggle so the `isquickpick` flag stays honest.
class QuickPicksBloc extends Bloc<QuickPicksEvent, QuickPicksState> {
  final d.Dio _dio = authDio();

  QuickPicksBloc() : super(const QuickPicksState()) {
    on<LoadQuickPicks>(_onLoad);
    on<AddToQuickPicks>(_onAdd);
    on<RemoveFromQuickPicks>(_onRemove);
    on<QuickPicksOperationCompleted>(_onCompleted);
  }

  Future<void> _onLoad(LoadQuickPicks event, Emitter<QuickPicksState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final (all, picks) = await _fetchBoth();
      emit(state.copyWith(allSongs: all, quickPicks: picks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: () => 'Failed to load songs: $e',
        toastSuccess: () => false,
      ));
    }
  }

  Future<void> _onAdd(AddToQuickPicks event, Emitter<QuickPicksState> emit) =>
      _toggle(emit, event.song, addToQuickPicksUrl,
          {'songid': event.song.songid, 'isquickpick': 1},
          'Added to quick picks.');

  Future<void> _onRemove(RemoveFromQuickPicks event, Emitter<QuickPicksState> emit) =>
      _toggle(emit, event.song, removeFromQuickPicksUrl,
          {'songid': event.song.songid}, 'Removed from quick picks.');

  Future<void> _toggle(Emitter<QuickPicksState> emit, MySongs song, String url,
      Map<String, dynamic> body, String okMessage) async {
    emit(state.copyWith(busyId: () => song.songid));
    try {
      final response = await _dio.post(url, data: body);
      final success = response.statusCode == 200 && response.data['success'] == true;
      if (!success) {
        emit(state.copyWith(
          busyId: () => null,
          toastMessage: () => 'That didn\'t work — please try again.',
          toastSuccess: () => false,
        ));
        return;
      }
      // Refetch both lists so the row moves columns; the write already
      // succeeded, so a failed refetch still reports success.
      try {
        final (all, picks) = await _fetchBoth();
        emit(state.copyWith(allSongs: all, quickPicks: picks));
      } catch (_) {}
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => okMessage,
        toastSuccess: () => true,
      ));
    } catch (e) {
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => 'Network error: unable to connect.',
        toastSuccess: () => false,
      ));
    }
  }

  Future<(List<MySongs>, List<MySongs>)> _fetchBoth() async {
    final results = await Future.wait([
      _dio.get(adminGetAllSongsUrl),
      _dio.get(getQuickPicksUrl),
    ]);
    List<MySongs> parse(dynamic data) => (data['data'] as List? ?? const [])
        .map((e) => MySongs.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (parse(results[0].data), parse(results[1].data));
  }

  void _onCompleted(QuickPicksOperationCompleted event, Emitter<QuickPicksState> emit) {
    emit(state.copyWith(toastMessage: () => null, toastSuccess: () => null));
  }
}
