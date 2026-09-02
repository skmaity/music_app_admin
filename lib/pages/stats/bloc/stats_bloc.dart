import 'package:dio/dio.dart' as d;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/app_stats_model.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final d.Dio _dio = authDio();

  StatsBloc() : super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    // The previous numbers stay on screen through a refresh — `stats` is not
    // cleared here. A manual refresh should read as the figures updating, not
    // as the card emptying and refilling.
    emit(state.copyWith(isLoading: true, error: () => null));
    try {
      final response = await _dio.get(getAppStatsUrl);
      final body = response.data;
      final data = body is Map ? body['data'] : null;

      if (data is Map) {
        emit(state.copyWith(
          isLoading: false,
          stats: AppStats.fromJson(Map<String, dynamic>.from(data)),
        ));
        return;
      }

      // `success: false` with a real message — the usual one being that the
      // migration has not been run yet, which is worth showing verbatim rather
      // than flattening into "couldn't load".
      final message = (body is Map ? body['message'] : null)?.toString();
      emit(state.copyWith(
        isLoading: false,
        error: () => message?.isNotEmpty == true
            ? message!
            : "Couldn't read the stats response.",
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: () => "Couldn't reach the server.",
      ));
    }
  }
}
