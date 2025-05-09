import 'dart:ui';
import 'package:flutter/material.dart';

void showOverlayToast(BuildContext context,bool success, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(

    builder: (context) => Positioned(
      top: 20,
      right: 20,
      child: MyOverlay(
        message: message ,
        success: success,
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class MyOverlay extends StatefulWidget {
  final bool success;
  final String message;
  const MyOverlay({super.key, required this.success,required this.message});

  @override
  State<MyOverlay> createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 65,
        width: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.grey.shade200.withAlpha(70),
              ),
              padding: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        "hello how are you doing, hope you are all right and fine with you family",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return RotatedBox(
                        quarterTurns: 2,
                        child: LinearProgressIndicator(
                                value: 1.0 - _controller.value,
                                color: Colors.white.withAlpha(100),
                                backgroundColor: Colors.white.withAlpha(20),
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
    );
  }
}
