import 'package:equatable/equatable.dart';

/// One day of the activity chart.
class DayPoint extends Equatable {
  final DateTime day;

  /// Installs that opened the app on [day].
  final int active;

  /// Installs seen for the very first time on [day].
  final int newUsers;

  const DayPoint({
    required this.day,
    required this.active,
    required this.newUsers,
  });

  factory DayPoint.fromJson(Map<String, dynamic> json) => DayPoint(
        day: DateTime.tryParse('${json['day']}') ?? DateTime(1970),
        active: _asInt(json['active']),
        newUsers: _asInt(json['new']),
      );

  @override
  List<Object?> get props => [day, active, newUsers];
}

/// What `get_app_stats.php` reports.
///
/// Parsed defensively throughout — every field goes through [_asInt] and the
/// list through a `whereType` filter. `MySongs.fromJson` assumes every field is
/// present and correctly typed and crashes at runtime when one isn't; this is
/// the card on the home page, so a backend that answers with a missing key
/// should degrade to a zero, not take the whole panel down.
class AppStats extends Equatable {
  final int totalInstalls;
  final int activeToday;
  final int active7d;
  final int active30d;
  final int newToday;
  final int new7d;

  /// Oldest first, one entry per day, gaps already filled with zeros by the
  /// endpoint. Safe to index straight into a chart.
  final List<DayPoint> daily;

  const AppStats({
    required this.totalInstalls,
    required this.activeToday,
    required this.active7d,
    required this.active30d,
    required this.newToday,
    required this.new7d,
    required this.daily,
  });

  static const empty = AppStats(
    totalInstalls: 0,
    activeToday: 0,
    active7d: 0,
    active30d: 0,
    newToday: 0,
    new7d: 0,
    daily: [],
  );

  factory AppStats.fromJson(Map<String, dynamic> json) => AppStats(
        totalInstalls: _asInt(json['total_installs']),
        activeToday: _asInt(json['active_today']),
        active7d: _asInt(json['active_7d']),
        active30d: _asInt(json['active_30d']),
        newToday: _asInt(json['new_today']),
        new7d: _asInt(json['new_7d']),
        daily: (json['daily'] as List?)
                ?.whereType<Map>()
                .map((e) => DayPoint.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );

  /// True before anyone has ever been recorded — the card shows its "waiting
  /// for the first listener" state rather than a row of zeros and a flat line.
  bool get isEmpty => totalInstalls == 0;

  @override
  List<Object?> get props =>
      [totalInstalls, activeToday, active7d, active30d, newToday, new7d, daily];
}

/// PHP's JSON hands back ints as ints, but a `COUNT(*)` that travels through a
/// string column, or a null from a missing key, both turn up here. One coercion
/// rather than a cast that throws.
int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
