import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FireStoreServices extends GetxController {
  // final db = FirebaseFirestore.instance;

  loginFunction(String userid, String pass, context) async {

    // final songsCollection = await db.collection('admins').doc(userid).get();
    // if (songsCollection.data()!.isNotEmpty) {
    //   Map<String, dynamic> admininfo = songsCollection.data()!;
    //   if (admininfo['id'] == userid && admininfo['pass'] == pass) {
    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
    //         ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('admin login successful')),
    // );
    //   }
    //   else{
    // ScaffoldMessenger.of(context).showSnackBar( 
    //   const SnackBar(content: Text('Wrong id or password')),
    // );
    //   }
    // }
  }
Future<void> addSong(Uint8List? coverImg, Uint8List? songFile, String artist, String title, BuildContext context) async {
  // try {
  //   if (coverImg == null || songFile == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please pick a cover and song file')),
  //     );
  //     return;
  //   }

  //   // Firebase instances
  //   final FirebaseStorage storage = FirebaseStorage.instance;
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //   // Generate a unique song ID
  //   String songId = const Uuid().v4();

  //   // Create unique file names using songId
  //   String coverFileName = "covers/$songId.jpg";
  //   String songFileName = "songs/$songId.mp3";

  //   // Upload cover image
  //   TaskSnapshot coverSnapshot = await storage.ref(coverFileName).putData(coverImg);
  //   String coverUrl = await coverSnapshot.ref.getDownloadURL();

  //   // Upload song file
  //   TaskSnapshot songSnapshot = await storage.ref(songFileName).putData(songFile);
  //   String songUrl = await songSnapshot.ref.getDownloadURL();

  //   // Store data in Firestore
  //   await firestore.collection('songs').doc(songId).set({
  //     'artist': artist,
  //     'title': title,
  //     'cover': coverUrl,
  //     'song': songUrl,
  //     'songid': songId,
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Song uploaded successfully!')),
  //   );

  // } catch (e) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Upload failed: $e')),
  //   );
  // }
}

}
