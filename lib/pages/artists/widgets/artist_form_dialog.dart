import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_app_admin/models/artist_model.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// What the dialog hands back once the form validates.
typedef ArtistSubmit = void Function(String name, String bio, PlatformFile? image);

/// Pass [artist] to edit, omit it to create.
///
/// The dialog takes [onSubmit] rather than a bloc because both the grid and
/// the detail page open it, and they dispatch to different blocs. Read that
/// bloc in the caller — this is pushed on the root navigator, above either
/// provider.
Future<void> showArtistFormDialog(
  BuildContext context, {
  required ArtistSubmit onSubmit,
  Artist? artist,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => ArtistFormDialog(onSubmit: onSubmit, artist: artist),
  );
}

class ArtistFormDialog extends StatefulWidget {
  const ArtistFormDialog({super.key, required this.onSubmit, this.artist});

  final ArtistSubmit onSubmit;
  final Artist? artist;

  @override
  State<ArtistFormDialog> createState() => _ArtistFormDialogState();
}

class _ArtistFormDialogState extends State<ArtistFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name =
      TextEditingController(text: widget.artist?.name ?? '');
  late final TextEditingController _bio =
      TextEditingController(text: widget.artist?.bio ?? '');

  PlatformFile? _image;

  bool get _isEdit => widget.artist != null;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes != null) setState(() => _image = file);
  }

  /// Hands the write to the caller and closes — the card spinner and the toast
  /// are the feedback, same as every other write in the panel.
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(_name.text.trim(), _bio.text.trim(), _image);
    Navigator.pop(context);
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelStyle: const TextStyle(color: Colors.white),
        suffixIcon: Icon(icon, color: Colors.white70),
        errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
        alignLabelWithHint: true,
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
                  Text(
                    _isEdit ? 'Edit Artist' : 'New Artist',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, shadows: _glow),
                  ),
                  const SizedBox(height: 20),
                  _imagePreview(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: Text(
                        _image?.name ??
                            (_isEdit ? 'Replace banner' : 'Choose a banner'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Name', Icons.person_outline),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bio,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _decoration('Bio (optional)', Icons.notes_outlined),
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
                        icon: Icon(
                            _isEdit ? Icons.save_outlined : Icons.add, size: 18),
                        label: Text(_isEdit ? 'Save changes' : 'Create artist'),
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

  /// 16:9, matching how the banner is actually used on the card and header.
  Widget _imagePreview() {
    final existing = widget.artist?.imageLink;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.grey.shade200.withAlpha(60),
          child: _image?.bytes != null
              ? Image.memory(_image!.bytes!, fit: BoxFit.cover)
              : existing == null
                  ? const Center(
                      child: Icon(Icons.person, color: Colors.white70, size: 44))
                  : CachedNetworkImage(
                      imageUrl: existing,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.image_outlined,
                              color: Colors.white70, size: 44)),
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 0.5),
                      ),
                    ),
        ),
      ),
    );
  }
}
