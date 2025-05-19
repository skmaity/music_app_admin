import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/addsongs_page/add_songs_functions.dart';
import 'package:music_app_admin/pages/addsongs_page/controllers/add_songs_controller.dart';
import 'package:music_app_admin/services.dart';
import 'package:music_app_admin/widgets/alert_msg/alert_msg.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class AddSongsPage extends StatefulWidget {
  const AddSongsPage({super.key});

  @override
  State<AddSongsPage> createState() => _AddSongsPageState();
}

class _AddSongsPageState extends State<AddSongsPage> {
  int containerOpacity = 60;
  int borderOpacity = 70;

  final _formKey = GlobalKey<FormState>();

  TextEditingController artist = TextEditingController();
  TextEditingController cover = TextEditingController();
  TextEditingController song = TextEditingController();
  TextEditingController title = TextEditingController();

  late AddSongsFunctions _functions;

  double albumSize = 150.0;
  // late FireStoreServices service;
 
 AddSongsController controller = Get.find<AddSongsController>();
  @override
  void initState() {
    _functions = Get.put(AddSongsFunctions());
    // service = FireStoreServices();  

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center( 
              child: Container(
                padding: EdgeInsets.all(20),
                height: 600,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: Colors.grey.shade200.withAlpha(borderOpacity)),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200.withAlpha(containerOpacity),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Show the picked image (if any)
                          if (_functions.pickedImg != null)
                            Container(
                              height: albumSize,
                              width: albumSize,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                      image: MemoryImage(_functions.pickedImg!),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 20,
                                        color: Colors.white,
                                        offset: Offset(0, 0))
                                  ]),
                            )
                          else
                            Container(
                              height: albumSize,
                              width: albumSize,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withAlpha(180)),
                              child: Center(child: Icon(Icons.image_outlined)),
                            ),

                          // TextButton for picking the image
                          TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () {
                              _functions
                                  .pickImageFile()
                                  .whenComplete(() => setState(() {}));
                            },
                            icon: Icon(
                              Icons.photo_album_outlined,
                              color: Colors.white,
                              shadows: [ 
                                const Shadow(
                                    blurRadius: 9.0,
                                    color: Colors.white,
                                    offset: Offset(0, 0))
                              ],
                              size: 20,
                            ),
                            label: Text(
                              'Pick Cover',
                              style: TextStyle(
                                shadows: [
                                  const Shadow(
                                      blurRadius: 9.0,
                                      color: Colors.white,
                                      offset: Offset(0, 0)),
                                ],
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _functions.pickedSongData.isNotEmpty
                                    ? Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${_functions.pickedSongData['fileName']}.${_functions.pickedSongData['fileExtension']}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                shadows: [
                                                  const Shadow(
                                                      blurRadius: 9.0,
                                                      color: Colors.white,
                                                      offset: Offset(0, 0)),
                                                ],
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              _functions
                                                      .pickedSongData.isNotEmpty
                                                  ? "${_functions.pickedSongData['fileSize']} MB"
                                                  : 'null',
                                              style: TextStyle(
                                                shadows: [
                                                  const Shadow(
                                                      blurRadius: 9.0,
                                                      color: Colors.amber,
                                                      offset: Offset(0, 0)),
                                                ],
                                                color: Colors.amber[100],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        'Pick a song to see\ndetails',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          shadows: [
                                            const Shadow(
                                                blurRadius: 9.0,
                                                color: Colors.white,
                                                offset: Offset(0, 0)),
                                          ],
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () { 
                              _functions
                                  .pickSongFile()
                                  .whenComplete(() => setState(() {
                                        if (_functions
                                            .pickedSongData.isNotEmpty) {
                                          song.text =
                                              "${_functions.pickedSongData['fileName']}.${_functions.pickedSongData['fileExtension']}";
                                        }
                                      }));
                            },
                            icon: Icon(
                              Icons.music_note_rounded,
                              color: Colors.white,
                              shadows: [
                                const Shadow(
                                    blurRadius: 9.0,
                                    color: Colors.white,
                                    offset: Offset(0, 0))
                              ],
                              size: 20,
                            ),
                            label: Text(
                              'Pick Song',
                              style: TextStyle(
                                shadows: [
                                  const Shadow(
                                      blurRadius: 9.0,
                                      color: Colors.white,
                                      offset: Offset(0, 0)),
                                ],
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: artist,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  alignLabelWithHint: true,

                                  // normal border
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),

                                  // focused border
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  suffixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  hintText: "Artist",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                                          autovalidateMode: AutovalidateMode.onUnfocus,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: title,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  alignLabelWithHint: true,

                                  // normal border
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),

                                  // focused border
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  suffixIcon: Icon(
                                    Icons.title,
                                    color: Colors.white,
                                  ),
                                  hintText: "Title",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                                          autovalidateMode: AutovalidateMode.onUnfocus,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      iconAlignment: IconAlignment.end,
                       onPressed: () {
    if (_functions.pickedImg == null || _functions.pickedSong == null) {
      showOverlayToast(context, false, 'Please pick a cover and song file');
      return;
    }

    if (_formKey.currentState!.validate()) {
      controller.addSong(     
          _functions.pickedImg, _functions.pickedSong, artist.text, title.text,context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
    }
    else{ 
      showOverlayToast(Get.context!, false, 'Please fill all the fields');
    }
  },
                      icon: null,
                      label: Text(
                        'Add Song',
                        style: TextStyle(shadows: [
                          const Shadow(
                              blurRadius: 9.0,
                              color: Colors.white,
                              offset: Offset(0, 0))
                        ], color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
