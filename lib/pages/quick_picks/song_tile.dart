import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/quick_picks/models/song_model.dart';
import 'package:music_app_admin/url_admin.dart';

class SongTile extends StatelessWidget {
  final MySongs song; 
  final bool isQuickPick;
  final void Function()? onIconBtnPressed;
  final void Function()? onpressed;
  final bool isLoading;

  const SongTile({
    super.key,
    this.isQuickPick = false,
    required this.song,
    required this.onIconBtnPressed,
    required this.onpressed,
    this.isLoading = false,
  });

  void showHoverDialog(BuildContext context, MySongs song) {
    if (Get.isDialogOpen ?? false) return; // Prevent multiple dialogs
    Get.dialog(

      Dialog(
        alignment: Alignment(0, 0),
        backgroundColor: Colors.white.withAlpha(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: context.width * 0.2,
              height: context.height * 0.5,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade200.withAlpha(70), width: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox( 
                        
                                  
                                    child: CachedNetworkImage(imageUrl: song.coverurl, 
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                      return const Icon(Icons.error, color: Colors.red);
                                      },
                                      placeholder: (context, url) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white,
                        strokeWidth: 0.5,
                        ),
                      );
                                      },
                                    ),
                                  ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Title: ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Artist: ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withAlpha(30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          hoverColor: const Color(0xFF1F1F1F),
          splashColor: const Color.fromARGB(255, 70, 70, 70),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          onTap: () {
            showHoverDialog(context, song);
          },
          tileColor: Colors.grey.shade100.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              width: 0.5,
              color: Colors.grey.shade200.withOpacity(0.5),
            ),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox( 
              height: 50,
              width: 50,
              // child: CachedNetworkImage(imageUrl: "${baseUrl}${song.coverurl}",
              child: CachedNetworkImage(imageUrl: "https://fluttersubh.fun/music_apis/uploads/covers/cover_682778fd4f0723.48621579.jpg",

              
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return const Icon(Icons.error, color: Colors.red);
                },
                placeholder: (context, url) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white,
                    strokeWidth: 0.5,
                    ),
                  );
                },
              ),
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(color: Colors.white),
            maxLines: 1,
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(color: Colors.white, fontSize: 12),
            maxLines: 1,
          ),
  trailing: isLoading
      ? Padding(
        padding: const EdgeInsets.only(right: 7),
        child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 0.5,
            ),
          ),
      )
      : IconButton(
          hoverColor: isQuickPick ? Colors.orange : Colors.greenAccent,
          icon: Icon(
            isQuickPick ? Icons.remove : Icons.add,
            color: Colors.white,
          ),
          onPressed: onIconBtnPressed,
        ),
        ),
      ),
    );
  }
}
