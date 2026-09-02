import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';
import 'package:url_launcher/url_launcher.dart';

const _glow = [
  Shadow(blurRadius: 9, color: Colors.white, offset: Offset.zero),
];

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static final Uri _apkUrl = Uri.base.resolve('downloads/nyro.apk');

  Future<void> _download(BuildContext context) async {
    if (!await launchUrl(_apkUrl, webOnlyWindowName: '_self') &&
        context.mounted) {
      showOverlayToast(context, false, 'The download could not be started.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/my_bg_2.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          ColoredBox(color: Colors.black.withAlpha(125)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    children: [
                      _nav(context),
                      const SizedBox(height: 72),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 820;
                          final intro = _intro(context, compact);
                          final preview = _preview();
                          return compact
                              ? Column(children: [
                                  intro,
                                  const SizedBox(height: 40),
                                  preview,
                                ])
                              : Row(children: [
                                  Expanded(flex: 6, child: intro),
                                  const SizedBox(width: 56),
                                  Expanded(flex: 4, child: preview),
                                ]);
                        },
                      ),
                      const SizedBox(height: 72),
                      _details(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 480;
          return Row(
            children: [
              SizedBox(
                width: compact ? 120 : 190,
                height: compact ? 42 : 66,
                child: Image.asset(
                  'assets/nyro_full_logo.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'Nyro',
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(compact ? 'Admin' : 'Admin login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 18,
                    vertical: compact ? 10 : 14,
                  ),
                ),
              ),
            ],
          );
        },
      );

  Widget _intro(BuildContext context, bool compact) => Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            'MUSIC, YOUR WAY',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Find your sound.\nPress play.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 46 : 64,
              height: 1.02,
              fontWeight: FontWeight.w700,
              shadows: _glow,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              'Nyro brings quick picks, artist discovery, search and your '
              'favourites into one focused music player. Stream instantly and '
              'keep listening with background playback.',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _download(context),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download for Android'),
            style: FilledButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              textStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'APK - Version 1.0.0 - 57 MB',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      );

  Widget _preview() => Semantics(
        label: 'Nyro app feature preview',
        child: _glass(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipOval(
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: 128,
                    height: 128,
                    child: Image.asset(
                      'assets/nyro_logo.png',
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Made for the music,\nnot the menu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  shadows: _glow,
                ),
              ),
              const SizedBox(height: 24),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Feature(Icons.bolt_rounded, 'Quick picks'),
                  _Feature(Icons.search_rounded, 'Search'),
                  _Feature(Icons.favorite_rounded, 'Favourites'),
                  _Feature(Icons.headphones_rounded, 'Background play'),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _details() => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final how = _glass(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                    Icons.play_circle_outline_rounded, 'How it works'),
                SizedBox(height: 20),
                _Step('01', 'Discover', 'Browse quick picks and artists.'),
                _Step('02', 'Choose', 'Search or open a favourite track.'),
                _Step(
                    '03', 'Listen', 'Play music even when the screen is off.'),
              ],
            ),
          );
          final tech = _glass(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(Icons.code_rounded, 'Built with'),
                SizedBox(height: 20),
                Text(
                  'A Flutter Android app backed by a PHP and MySQL API, '
                  'with Dio networking and just_audio playback.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 16, height: 1.55),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tech('Flutter'),
                    _Tech('Dart'),
                    _Tech('PHP'),
                    _Tech('MySQL'),
                    _Tech('Dio'),
                    _Tech('just_audio'),
                  ],
                ),
              ],
            ),
          );
          return compact
              ? Column(children: [how, const SizedBox(height: 20), tech])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: how),
                  const SizedBox(width: 20),
                  Expanded(child: tech),
                ]);
        },
      );

  Widget _glass(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.all(28)}) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200.withAlpha(90)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: padding,
              color: Colors.grey.shade200.withAlpha(60),
              child: child,
            ),
          ),
        ),
      );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withAlpha(40),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: Colors.white, shadows: _glow),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              shadows: _glow,
            ),
          ),
        ),
      ]);
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.title, this.description);

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(width: 14),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$title  ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _Tech extends StatelessWidget {
  const _Tech(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white70)),
      );
}
