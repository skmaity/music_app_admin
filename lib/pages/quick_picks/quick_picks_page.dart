import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/pages/quick_picks/controller/quick_picks_controller.dart';
import 'package:music_app_admin/pages/quick_picks/song_tile.dart';

class QuickPicksPage extends StatefulWidget {
  const QuickPicksPage({super.key});

  @override
  State<QuickPicksPage> createState() => _QuickPicksPageState();
}

class _QuickPicksPageState extends State<QuickPicksPage> {
  QuickPicksController quickPicksController = Get.put(QuickPicksController());

  @override
  void initState() {
    super.initState(); 
    quickPicksController.getAllSongs(Get.context!); 
    quickPicksController.getQuickPicks(context); 
  }
  int containerOpacity = 60;
  int borderOpacity = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Quick Picks
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.shade200.withAlpha(borderOpacity),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200.withAlpha(containerOpacity),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Quick Picks",
                      style: TextStyle(
                        shadows: [
                          Shadow(
                            blurRadius: 9.0,
                            color: Colors.white,
                            offset: Offset(0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      ()=> Expanded(
                        child: ListView.builder(
                          itemCount: quickPicksController.quickPicks.length,
                          itemBuilder: (context, index) {
                            return SongTile(  
                            isQuickPick: true,
                              song: quickPicksController.quickPicks[index],
                              onIconBtnPressed: () {
                                  quickPicksController.removeFromQuickPicks(quickPicksController.quickPicks[index],context).then((v){
quickPicksController.getQuickPicks(context);

                                  });

                              },
                              onpressed: () {},
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // All Songs
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.shade200.withAlpha(borderOpacity),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200.withAlpha(containerOpacity),
                ),
                child: Column(
                  children: [
                    const Text(
                      "All Songs",
                      style: TextStyle(
                        shadows: [
                          Shadow(
                            blurRadius: 9.0,
                            color: Colors.white,
                            offset: Offset(0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      ()=> Expanded(
                        child: ListView.builder(  
                          itemCount: quickPicksController.allSongs.length,
                          itemBuilder: (context, index) {
                            return Obx(
                              ()=> SongTile(       
                              isLoading: quickPicksController.isLoading.value,
                                song: quickPicksController.allSongs[index],
                                onIconBtnPressed: () {  
                                quickPicksController.addToQuickPicks(quickPicksController.allSongs[index], context) .then((v){
quickPicksController.getQuickPicks(context);
                                });
                                },
                                onpressed: () {},
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
