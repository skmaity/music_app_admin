import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/addsongs_page/controllers/add_songs_controller.dart';

const _glow = [Shadow(blurRadius: 9.0, color: Colors.white, offset: Offset(0, 0))];

/// Review sheet for the files picked by [AddSongsController.pickBulkSongs]:
/// shows the tags read from every file and uploads them all in one go.
Future<void> showBulkUploadDialog(
  BuildContext context,
  AddSongsController controller,
) {
  final size = MediaQuery.sizeOf(context);

  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(30),
    builder: (context) => Dialog(
      backgroundColor: Colors.white.withAlpha(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: min(560, size.width * 0.9),
            height: size.height * 0.75,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade200.withAlpha(70), width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bulk Upload',
                  style: TextStyle(
                      shadows: _glow, color: Colors.white, fontSize: 26),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      _subtitle(controller),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    )),
                Obx(() {
                  final missing =
                      controller.bulkSongs.where((s) => s.cover == null).length;
                  if (missing == 0) return const SizedBox(height: 12);

                  final cover = controller.bulkCover.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 12),
                    child: Row(
                      children: [
                        if (cover != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(cover,
                                height: 28, width: 28, fit: BoxFit.cover),
                          ),
                        if (cover != null) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cover != null
                                ? 'This cover will be used for $missing file'
                                    '${missing == 1 ? '' : 's'} without album art'
                                : '$missing file${missing == 1 ? ' has' : 's have'} '
                                    'no album art — pick a cover for them',
                            style: TextStyle(
                                color: Colors.amber[100], fontSize: 11),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.isUploading.value
                              ? null
                              : controller.pickBulkCover,
                          child: Text(
                            cover != null ? 'Change' : 'Pick cover',
                            style: const TextStyle(
                                shadows: _glow,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.bulkSongs.length,
                      itemBuilder: (context, i) => _SongRow(
                        song: controller.bulkSongs[i],
                        onRemove: controller.isUploading.value
                            ? null
                            : () => controller.bulkSongs.removeAt(i),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.isUploading.value
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                              shadows: _glow,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                      TextButton.icon(
                        iconAlignment: IconAlignment.end,
                        onPressed: controller.isUploading.value ||
                                controller.bulkSongs.isEmpty
                            ? null
                            : () => controller.uploadBulkSongs(context),
                        icon: const Icon(Icons.cloud_upload_outlined,
                            color: Colors.white, shadows: _glow, size: 20),
                        label: Text(
                          controller.isUploading.value
                              ? 'Uploading…'
                              : 'Upload all (${controller.bulkSongs.length})',
                          style: const TextStyle(
                              shadows: _glow,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ).then((_) => controller.bulkSongs.clear());
}

String _subtitle(AddSongsController controller) {
  final total = controller.bulkSongs.length;
  final done =
      controller.bulkSongs.where((s) => s.status == BulkStatus.done).length;
  if (controller.isUploading.value) return 'Uploading… $done of $total done';
  if (done > 0) return '$done of $total uploaded';
  return '$total song${total == 1 ? '' : 's'} • details read from the files';
}

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.onRemove});

  final BulkSong song;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final details = [song.artist, if (song.album.isNotEmpty) song.album];
    final failed = song.status == BulkStatus.failed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(width: 0.5, color: Colors.grey.shade200.withAlpha(70)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 48,
              width: 48,
              child: song.cover != null
                  ? Image.memory(song.cover!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.white.withAlpha(40),
                      child: const Icon(Icons.music_note_rounded,
                          color: Colors.white70, size: 20),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  failed ? (song.error ?? 'Upload failed') : details.join('  •  '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: failed ? Colors.red[100] : Colors.white70,
                      fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, height: 32, child: _status()),
        ],
      ),
    );
  }

  Widget _status() {
    switch (song.status) {
      case BulkStatus.uploading:
        return const Padding(
          padding: EdgeInsets.all(7),
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      case BulkStatus.done:
        return const Icon(Icons.check_circle,
            color: Colors.greenAccent, size: 20);
      case BulkStatus.failed:
        return Tooltip(
          message: song.error ?? 'Upload failed',
          child: const Icon(Icons.error_outline,
              color: Colors.redAccent, size: 20),
        );
      case BulkStatus.ready:
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Remove',
          onPressed: onRemove,
          icon: const Icon(Icons.close, color: Colors.white70, size: 18),
        );
    }
  }
}
