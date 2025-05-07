import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/add_artist_page.dart';
import 'package:music_app_admin/pages/addsongs/add_songs_page.dart';
import 'package:music_app_admin/pages/quick_picks/quick_picks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RxInt pageIndex = 1.obs;
  int containerOpacity = 80;
  int borderOpacity = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
              Get.to(()=>AddSongsPage(),
              transition: Transition.rightToLeft
              );
                },
                child: Container(
              
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color:Colors.grey.shade200.withAlpha(borderOpacity)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200.withAlpha(containerOpacity),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          iconAlignment: IconAlignment.end,
                          onPressed:null,
                          icon: Icon(
                            
                                 Icons.music_note,
                              
                            color:
                                Colors.white,
                            shadows: 
                               [
                                    const Shadow(
                                        blurRadius: 9.0,
                                        color: Colors.white,
                                        offset: Offset(0, 0))
                                  ],
                               
                            size: 20,
                          ),
                          label: Text(
                            'Add Songs',
                            style: TextStyle(
                              shadows:
                                  [
                                      const Shadow(
                                          blurRadius: 9.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0))
                                    ],
                                  
                              color: 
                                 Colors.white
                                
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (){
                Get.to(()=>QuickPicksPage(),
              transition: Transition.rightToLeft
              );
                  },
                child: Container(
                 
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color:Colors.grey.shade200.withAlpha(borderOpacity)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200.withAlpha(containerOpacity),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: null,
                            icon: Icon(
                              
                                   Icons.hotel_class_rounded,
                                
                              color:
                                   Colors.white,
                                 
                              shadows: 
                                   [
                                      const Shadow(
                                          blurRadius: 9.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0))
                                    ],
                                 
                              size: 20,
                            ),
                            label: Text(
                              'Quick picks',
                              style: TextStyle(
                                shadows: [
                                        const Shadow(
                                            blurRadius: 9.0,
                                            color: Colors.white,
                                            offset: Offset(0, 0))
                                      ]
                                ,
                                color:
                                     Colors.white
                                   
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
              Get.to(()=>AddArtistPage(),
              transition: Transition.rightToLeft
              );
                },
                child: Container(
                  
                    height: 80,
                   decoration: BoxDecoration(
                      border: Border.all(width: 1,color:Colors.grey.shade200.withAlpha(borderOpacity)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200.withAlpha(containerOpacity),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          iconAlignment: IconAlignment.end,
                          onPressed: null,
                          icon: Icon(
                             Icons.person,
                               
                            color:
                               Colors.white,
                            shadows: [
                                    const Shadow(
                                        blurRadius: 9.0,
                                        color: Colors.white,
                                        offset: Offset(0, 0))
                                  ],
                             
                            size: 20,
                          ),
                          label: Text(
                            'Add Artists',
                            style: TextStyle(
                              shadows: [
                                      const Shadow(
                                          blurRadius: 9.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0))
                                    ]
                              ,
                              color: 
                                Colors.white
                                ,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
