import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/pages/artists/bloc/artist_detail_bloc.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// Mounted on the root navigator, above the [ArtistDetailBloc] provider, so
/// the bloc is read here and handed over directly.
Future<void> showAddArtistSongDialog(BuildContext context, String artistName) {
  final bloc = context.read<ArtistDetailBloc>();
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => AddArtistSongDialog(bloc: bloc, artistName: artistName),
  );
}

/// Uploads a brand-new song straight onto this artist. The credit is implied
/// by where you are, so the artist is shown but not editable.
class AddArtistSongDialog extends StatefulWidget {
  const AddArtistSongDialog({
    super.key,
    required this.bloc,
    required this.artistName,
  });

  final ArtistDetailBloc bloc;
  final String artistName;

  @override
  State<AddArtistSongDialog> createState() => _AddArtistSongDialogState();
}

class _AddArtistSongDialogState extends State<AddArtistSongDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();

  PlatformFile? _cover;
  PlatformFile? _audio;

  /// The endpoint rejects the upload without both files, so say so here
  /// rather than letting the request fail.
  String? _fileError;

  @override
  void dispose() {
    _title.dispose();
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

  void _upload() {
    final missingFiles = _cover == null || _audio == null;
    setState(() => _fileError =
        missingFiles ? 'Pick both a cover image and an audio file.' : null);

    if (!_formKey.currentState!.validate() || missingFiles) return;

    widget.bloc.add(AddSongToArtist(_title.text.trim(), _cover!, _audio!));
    Navigator.pop(context);
  }

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
              border: Border.all(color: Colors.grey.shade200.withAlpha(70), width: 1),
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200.withAlpha(60),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upload new song',
                      style: TextStyle(
                          color: Colors.white, fontSize: 24, shadows: _glow)),
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
                              label: _cover == null ? 'Choose cover' : 'Cover picked',
                              onPressed: () => _pick(
                                const ['jpg', 'jpeg', 'png', 'webp'],
                                (f) => _cover = f,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _fileButton(
                              icon: Icons.music_note_rounded,
                              label: _audio == null ? 'Choose audio' : 'Audio picked',
                              onPressed: () => _pick(
                                const ['mp3', 'wav', 'aac', 'ogg', 'flac'],
                                (f) => _audio = f,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _audio?.name ?? 'No audio file chosen',
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
                  if (_fileError != null) ...[
                    const SizedBox(height: 12),
                    Text(_fileError!,
                        style: const TextStyle(
                            color: Color(0xFFFFB4AB), fontSize: 11)),
                  ],
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
                  _fixedArtist(),
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
                        onPressed: _upload,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: const Text('Upload'),
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

  /// Read-only rather than disabled: the value is real and final, it is simply
  /// not this dialog's to change.
  Widget _fixedArtist() => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Artist',
          labelStyle: const TextStyle(color: Colors.white70),
          suffixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          helperText: 'Set by the artist page you came from',
          helperStyle: const TextStyle(color: Colors.white70, fontSize: 11),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withAlpha(40)),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: Text(widget.artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white)),
      );

  Widget _coverPreview() => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 110,
          width: 110,
          child: ColoredBox(
            color: Colors.grey.shade200.withAlpha(60),
            child: _cover?.bytes != null
                ? Image.memory(_cover!.bytes!, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.image_outlined, color: Colors.white70)),
          ),
        ),
      );

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
