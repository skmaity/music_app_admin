import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app_admin/login_page/controller/login_controller.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  LoginController controller = Get.find<LoginController>();
  int containerOpacity = 60;
  int borderOpacity = 70;
  TextEditingController userid = TextEditingController();
  TextEditingController pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 200),
      vsync: this,
    )..repeat();
    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            // Animated moving background image
            AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, child) {
                return Positioned(
                  left: (_bgAnimation.value * -(3840)),
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/my_bg_2.png',
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'assets/my_bg_2.png',
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'assets/my_bg_2.png',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: width,
            ),

            Positioned.fill(
              child: Row(
                children: [
                  Image.asset(
                    width: width,
                    height: MediaQuery.of(context).size.height,
                    'assets/gradient_layer.png',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      width: 0.5,
                      color: Colors.grey.shade200.withAlpha(borderOpacity)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade200.withAlpha(containerOpacity),
                      ),
                      // height: 400,
                      width: 350,
                      child: Form(
                        //  autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: FlutterLogo(
                                size: 50,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: userid,
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
                                    Icons.music_note_rounded,
                                    color: Colors.white,
                                  ),
                                  hintText: "User_id",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: pass,
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
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                    ),
                                    hintText: "Pass",
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 80,
                            ),
                            TextButton.icon(
                              iconAlignment: IconAlignment.end,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.logAdmin(userid.text, pass.text);
                                }
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
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
                                'Submit',
                                style: TextStyle(shadows: [
                                  const Shadow(
                                      blurRadius: 9.0,
                                      color: Colors.white,
                                      offset: Offset(0, 0)),
                                ], color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
