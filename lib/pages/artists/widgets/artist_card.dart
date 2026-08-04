import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app_admin/models/artist_model.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// One artist in the grid: a 16:9 banner with the name and song count laid
/// over it, and edit / delete in the top-right corner.
///
/// The actions stay visible rather than fading in on hover — this is the only
/// route to editing an artist, and a hover-only affordance hides it from touch
/// and keyboard users entirely.
class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.artist,
    required this.isBusy,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Artist artist;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final count = artist.totalSongs;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: Colors.grey.shade200.withAlpha(70)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // 16:9 is fixed up front so the grid never reflows as banners load in.
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _banner(),
              // Keeps the name legible over any image.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                    stops: [0, 0.7],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, shadows: _glow),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 1 ? '1 song' : '$count songs',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isBusy ? null : onTap,
                  hoverColor: Colors.white.withAlpha(20),
                  splashColor: Colors.white24,
                ),
              ),
              Positioned(top: 8, right: 8, child: _actions()),
            ],
          ),
        ),
      ),
    );
  }

  /// Backfilled artists have no image at all, so the placeholder has to look
  /// deliberate rather than broken.
  Widget _banner() {
    final url = artist.imageLink;
    if (url == null) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => _placeholder(),
      placeholder: (_, __) => ColoredBox(
        color: Colors.grey.shade200.withAlpha(60),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 0.5),
        ),
      ),
    );
  }

  Widget _placeholder() => ColoredBox(
        color: Colors.grey.shade200.withAlpha(60),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white70, size: 44),
        ),
      );

  Widget _actions() {
    if (isBusy) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 0.5),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(70),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit artist',
            visualDensity: VisualDensity.compact,
            hoverColor: Colors.white24,
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Delete artist',
            visualDensity: VisualDensity.compact,
            hoverColor: Colors.redAccent.withAlpha(60),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
