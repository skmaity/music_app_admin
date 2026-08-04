import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/pages/addsongs_page/bloc/add_songs_bloc.dart';
import 'package:music_app_admin/pages/addsongs_page/bulk_upload_dialog.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class AddSongsPage extends StatelessWidget {
  const AddSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddSongsBloc(),
      child: const _AddSongsView(),
    );
  }
}

class _AddSongsView extends StatefulWidget {
  const _AddSongsView();

  @override
  State<_AddSongsView> createState() => _AddSongsViewState();
}

class _AddSongsViewState extends State<_AddSongsView> {
  static const int _containerOpacity = 60;
  static const int _borderOpacity = 70;
  static const double _albumSize = 150.0;
  static const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController artist = TextEditingController();
  final TextEditingController title = TextEditingController();

  @override
  void dispose() {
    artist.dispose();
    title.dispose();
    super.dispose();
  }

  void _submit() {
    // The bloc raises its own "pick a cover and song" toast when files are
    // missing; here we only gate on the text fields.
    if (_formKey.currentState!.validate()) {
      context.read<AddSongsBloc>().add(
            SubmitSong(title: title.text.trim(), artist: artist.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddSongsBloc, AddSongsState>(
            listenWhen: (p, c) => c.message != null && c.message != p.message,
            listener: (context, state) => showOverlayToast(
                context, state.isSuccessMessage ?? false, state.message!),
          ),
          BlocListener<AddSongsBloc, AddSongsState>(
            listenWhen: (p, c) => c.showBulkDialog && !p.showBulkDialog,
            listener: (context, state) =>
                showBulkUploadDialog(context, context.read<AddSongsBloc>()),
          ),
        ],
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 600,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey.shade200.withAlpha(_borderOpacity)),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200.withAlpha(_containerOpacity),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _coverRow(),
                    _songRow(),
                    _fields(),
                    _actions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<AddSongsBloc, AddSongsState>(
              buildWhen: (p, c) => p.coverBytes != c.coverBytes,
              builder: (context, state) => state.coverBytes != null
                  ? Container(
                      height: _albumSize,
                      width: _albumSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                            image: MemoryImage(state.coverBytes!),
                            fit: BoxFit.cover),
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 20,
                              color: Colors.white,
                              offset: Offset(0, 0))
                        ],
                      ),
                    )
                  : Container(
                      height: _albumSize,
                      width: _albumSize,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withAlpha(180)),
                      child: const Center(child: Icon(Icons.image_outlined)),
                    ),
            ),
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () =>
                  context.read<AddSongsBloc>().add(PickCoverImage()),
              icon: const Icon(Icons.photo_album_outlined,
                  color: Colors.white, shadows: _glow, size: 20),
              label: const Text('Pick Cover',
                  style: TextStyle(
                      shadows: _glow, color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      );

  Widget _songRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: BlocBuilder<AddSongsBloc, AddSongsState>(
                buildWhen: (p, c) =>
                    p.songName != c.songName || p.songSize != c.songSize,
                builder: (context, state) => state.songBytes != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.songName ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                shadows: _glow,
                                color: Colors.white,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${state.songSize} MB',
                            style: TextStyle(
                              shadows: const [
                                Shadow(
                                    blurRadius: 9.0,
                                    color: Colors.amber,
                                    offset: Offset(0, 0))
                              ],
                              color: Colors.amber[100],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Pick a song to see\ndetails',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            shadows: _glow, color: Colors.white, fontSize: 12),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () => context.read<AddSongsBloc>().add(PickSongFile()),
              icon: const Icon(Icons.music_note_rounded,
                  color: Colors.white, shadows: _glow, size: 20),
              label: const Text('Pick Song',
                  style: TextStyle(
                      shadows: _glow, color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      );

  Widget _fields() => Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: artist,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Artist', Icons.person),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter some text' : null,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: title,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Title', Icons.title),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter some text' : null,
              ),
            ),
          ],
        ),
      );

  Widget _actions() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<AddSongsBloc, AddSongsState>(
            buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
            builder: (context, state) => state.isSubmitting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 1),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: const Text('Add Song',
                        style: TextStyle(
                            shadows: _glow, color: Colors.white, fontSize: 20)),
                  ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 80,
            width: 1.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withAlpha(_containerOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          TextButton(
            onPressed: () => context.read<AddSongsBloc>().add(PickBulkSongs()),
            child: const Text('Bulk upload',
                style: TextStyle(
                    shadows: _glow, color: Colors.white, fontSize: 20)),
          ),
        ],
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        alignLabelWithHint: true,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        suffixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
      );
}
