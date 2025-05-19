import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/state_manager.dart';

class AddSongsFunctions extends GetxController{
  Uint8List? pickedImg;
  Uint8List? pickedSong;

 
  Map<String , dynamic> pickedSongData = {};

Future<Uint8List?> pickImageFile() async {
  try {
 
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false, 
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List filePath = result.files.single.bytes!;
      pickedImg = filePath;
      
      return filePath;
    } else {
      // User canceled the picker
      return null;
    }
  } catch (e) {
    print('Error while picking file: $e');
    return null;
  }
}

Future<Uint8List?> pickSongFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'], // Add desired audio formats
      allowMultiple: false, 
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.single; // Access the selected file details

      // Get file properties
      String fileName = file.name; // File name
      String? fileExtension = file.extension; // File extension
      int fileSize = file.size; // File size in bytes
       double fileSizeMB = fileSize / (1024 * 1024); // Convert to MB
      Uint8List fileBytes = file.bytes!; // The song file as bytes

      pickedSongData={
'fileName': fileName,
'fileExtension': fileExtension ?? 'error',
'fileSize': fileSizeMB.toStringAsFixed(2)


      };
      pickedSong = fileBytes;



      print('File Name: $fileName');
      print('File Extension: $fileExtension');
      print('File Size: $fileSize bytes');

      return fileBytes;
    } else {
      // User canceled the picker
      return null;
    }
  } catch (e) {
    print('Error while picking file: $e');
    return null;
  }
}



} 