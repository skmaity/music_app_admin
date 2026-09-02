import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app_admin/pages/login_page/bloc/login_bloc.dart';
import 'package:music_app_admin/pages/login_page/repo/login_repo.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
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
    final size = MediaQuery.sizeOf(context);
    final backgroundWidth = size.height * 16 / 3;
    return BlocProvider(
      create: (context) => LoginBloc(repo: LoginRepo()),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            showOverlayToast(context, true, state.message);
            context.go('/home');
          } else if (state is LoginFailure) {
            showOverlayToast(context, false, state.message);
          }
        },
        child: Scaffold(
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
                  left: -_bgAnimation.value * backgroundWidth,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      for (var i = 0; i < 2; i++)
                        Image.asset(
                          'assets/my_bg_2.png',
                          width: backgroundWidth,
                          height: size.height,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(
              height: size.height,
              width: size.width,
            ),

            Positioned.fill(
              child: Row(
                children: [
                  Image.asset(
                    width: size.width,
                    height: size.height,
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
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                if (state is LoginLoading) {
                                  return const CircularProgressIndicator(color: Colors.white);
                                }
                                return TextButton.icon(
                                  iconAlignment: IconAlignment.end,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<LoginBloc>().add(
                                            LoginSubmitted(
                                              userId: userid.text,
                                              password: pass.text,
                                            ),
                                          );
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
                                );
                              },
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
        ),
      ),
    );
  }
}
