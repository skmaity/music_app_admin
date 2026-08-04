import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/all_songs/bloc/all_songs_bloc.dart';
import 'package:music_app_admin/url_admin.dart';

/// The dialog is pushed on the root navigator, which sits above the
/// [AllSongsBloc] provider, so the bloc is read here and handed over directly.
Future<void> showEditSongDialog(BuildContext context, MySongs song) {
  final bloc = context.read<AllSongsBloc>();
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => EditSongDialog(bloc: bloc, song: song),
  );
}

/// Edits one song. The cover and audio file are optional: leave them alone and
/// only the title / artist are changed.
class EditSongDialog extends StatefulWidget {
  const EditSongDialog({
    super.key,
    required this.bloc,
    required this.song,
  });

  final AllSongsBloc bloc;
  final MySongs song;

  @override
  State<EditSongDialog> createState() => _EditSongDialogState();
}

class _EditSongDialogState extends State<EditSongDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title =
      TextEditingController(text: widget.song.title);
  late final TextEditingController _artist =
      TextEditingController(text: widget.song.artist);

  PlatformFile? _cover;
  PlatformFile? _audio;

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    super.dispose();
  }

  Future<void> _pick(List<String> extensions, void Function(PlatformFile) keep) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes != null) setState(() => keep(file!));
  }

  /// Hands the edit to the bloc and closes. The row itself shows the spinner
  /// (via `busyId`) and the bloc raises the success / failure toast.
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    widget.bloc.add(UpdateSong(
      widget.song,
      _title.text.trim(),
      _artist.text.trim(),
      _cover,
      _audio,
    ));
    Navigator.pop(context);
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelStyle: const TextStyle(color: Colors.white),
        suffixIcon: Icon(icon, color: Colors.white70),
        errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.shade200.withAlpha(70), width: 1),
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200.withAlpha(60),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Song',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      shadows: [
                        Shadow(blurRadius: 9, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _coverPreview(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fileButton(
                              icon: Icons.photo_album_outlined,
                              label: _cover == null ? 'Change cover' : 'Cover picked',
                              onPressed: () => _pick(
                                const ['jpg', 'jpeg', 'png', 'webp'],
                                (f) => _cover = f,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _fileButton(
                              icon: Icons.music_note_rounded,
                              label: _audio == null ? 'Replace audio' : 'Audio picked',
                              onPressed: () => _pick(
                                const ['mp3', 'wav', 'aac', 'ogg', 'flac'],
                                (f) => _audio = f,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _audio?.name ?? widget.song.songurl.split('/').last,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _title,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Title', Icons.title),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _artist,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Artist', Icons.person),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Artist cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _coverPreview() => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 110,
          width: 110,
          child: _cover?.bytes != null
              ? Image.memory(_cover!.bytes!, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: "$baseUrl${widget.song.coverurl}",
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.image_outlined, color: Colors.white70),
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 0.5),
                  ),
                ),
        ),
      );

  Widget _fileButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white30),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      );
}
