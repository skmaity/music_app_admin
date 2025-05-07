import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_app_admin/login_page.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
 // hi how are you doing?
  // for a change
  @override 
  Widget build(BuildContext context) {
    return GetMaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       textButtonTheme:  TextButtonThemeData(
          style: ButtonStyle(textStyle:  WidgetStatePropertyAll(GoogleFonts.pacifico() ),),),
          textTheme: GoogleFonts.josefinSansTextTheme(),
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginPage()  
      // home: QuickPicksPage(),
    );
  }
}