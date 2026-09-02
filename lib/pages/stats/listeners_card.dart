import 'dart:ui';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/app_stats_model.dart';
import 'package:music_app_admin/pages/stats/bloc/stats_bloc.dart';

const _glow = [
  Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))
];

/// A floor, not a fixed height, so the card is the same size loading, failed,
/// empty or full — the left column holds the nav cards above it and the logout
/// button below, and both would jump if this grew when the request landed. Sized
/// to the loaded state; a hard height clipped it, because the text metrics it
/// would have to be tuned against change when Josefin Sans finishes loading.
const double _bodyMinHeight = 200;

/// "How many people are actually using the app", on the home page rather than
/// behind a route — it is the one number worth seeing every time the panel is
/// opened, and a page nobody visits inspires nobody.
///
/// Expects a [StatsBloc] above it.
class ListenersCard extends StatelessWidget {
  const ListenersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 0.5,
          color: Colors.grey.shade200.withAlpha(70),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200.withAlpha(60),
            ),
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<StatsBloc, StatsState>(
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, state),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: _bodyMinHeight),
                    child: _body(context, state),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, StatsState state) => Row(
        children: [
          const Icon(Icons.favorite_rounded,
              color: Colors.white, shadows: _glow, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Listeners',
            style: TextStyle(color: Colors.white, fontSize: 16, shadows: _glow),
          ),
          const Spacer(),
          // Sized down from the 48px default so it sits on the header line,
          // but the tap target keeps the full 40px box rather than shrinking
          // to the 18px glyph.
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Refresh',
              onPressed: state.isLoading
                  ? null
                  : () => context.read<StatsBloc>().add(const LoadStats()),
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: state.isLoading ? Colors.white38 : Colors.white70,
              ),
            ),
          ),
        ],
      );

  Widget _body(BuildContext context, StatsState state) {
    if (state.isFirstLoad) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child:
              CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
        ),
      );
    }

    final stats = state.stats;

    // Nothing loaded and the last attempt failed: the error is all there is to
    // show, so it gets the space and a way out. A retry, not just a message —
    // the usual cause is the migration not having been run yet, which is fixed
    // elsewhere and then re-checked here.
    if (stats == null) {
      return _message(
        context,
        icon: Icons.cloud_off_rounded,
        title: state.error ?? "Couldn't load stats.",
        detail: 'Check that migration_app_users.sql has been run and that '
            'get_app_stats.php is uploaded.',
        action: 'Try again',
      );
    }

    if (stats.isEmpty) {
      return _message(
        context,
        icon: Icons.hourglass_empty_rounded,
        title: 'No listeners recorded yet.',
        detail: 'Counting starts once an app release with the launch ping is '
            'out. The first person to open it shows up here.',
      );
    }

    return _numbers(stats, state.error);
  }

  Widget _numbers(AppStats stats, String? staleError) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _grouped(stats.totalInstalls),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.1,
              shadows: _glow,
              // Without this the digits are proportional, so the number's width
              // changes as it counts up and the caption under it shifts.
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            stats.totalInstalls == 1
                ? 'person has the app'
                : 'people have the app',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // The chart carries the shape of the trend; the peak is written out
          // beside it because a sparkline this size has no axis to read a value
          // off, and because a screen reader gets nothing from the path.
          Semantics(
            label: 'Daily listeners over the last ${stats.daily.length} days. '
                'Highest ${_peak(stats)}, today ${stats.activeToday}.',
            child: ExcludeSemantics(
              child: _Sparkline([for (final d in stats.daily) d.active]),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daily listeners · 30 days',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              Text(
                'peak ${_grouped(_peak(stats))}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat(_grouped(stats.activeToday), 'today'),
              _stat(_grouped(stats.active7d), 'this week'),
              _stat(_grouped(stats.new7d), 'new'),
            ],
          ),

          // A refresh that failed while numbers were already up. The figures
          // stay — they were true a moment ago — with a line saying they are
          // no longer being updated.
          if (staleError != null) ...[
            const SizedBox(height: 8),
            Text(
              staleError,
              style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 11),
            ),
          ],
        ],
      );

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      );

  Widget _message(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
    String? action,
  }) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            if (action != null)
              TextButton(
                onPressed: () =>
                    context.read<StatsBloc>().add(const LoadStats()),
                child: Text(
                  action,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
          ],
        ),
      );

  int _peak(AppStats stats) {
    var peak = 0;
    for (final d in stats.daily) {
      if (d.active > peak) peak = d.active;
    }
    return peak;
  }
}

/// Thousands separators without pulling in `intl` for one call site.
String _grouped(int n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

/// A 30-point single-series line. A `CustomPainter` rather than a chart
/// package: one series, no axes, no interaction, and the whole thing is the
/// forty lines below — `fl_chart` would be a dependency and a theme to fight
/// for exactly the same picture.
class _Sparkline extends StatelessWidget {
  const _Sparkline(this.values);

  final List<int> values;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 52),
        painter: _SparkPainter(values),
      );
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn first and always, so a run of quiet days still reads as a floor
    // rather than as an empty box.
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = Colors.white.withAlpha(40)
        ..strokeWidth = 1,
    );

    if (values.length < 2) return;

    var peak = 0;
    for (final v in values) {
      if (v > peak) peak = v;
    }
    // All zeros: every point sits on the baseline, which is the honest picture.
    // Guarded because it is also a division by zero.
    final scale = peak == 0 ? 1.0 : peak.toDouble();

    // Room for the stroke at full height, so the peak is not sliced in half by
    // the top edge.
    const top = 2.0;
    final usable = size.height - top;
    final dx = size.width / (values.length - 1);

    final line = Path();
    final fill = Path()..moveTo(0, size.height);

    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = top + usable - (values[i] / scale) * usable;
      i == 0 ? line.moveTo(x, y) : line.lineTo(x, y);
      fill.lineTo(x, y);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values);
}
