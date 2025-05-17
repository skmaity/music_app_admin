// import 'package:flutter/material.dart';

// class AlertMsg extends StatelessWidget {
//   final String title;
//   final String msg;
//   final bool isError;

//   const AlertMsg({
//     required this.title,
//     required this.msg,
//     this.isError = false,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300, // Optional: Set a width for consistent size
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.only(top: 40, right: 20),
//       decoration: BoxDecoration(
//         color: isError ? Colors.red : Colors.green,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             msg,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void showAlert(context, String title, String msg, {bool isError = false}) {
//   final overlay = Overlay.of(context);
//   final overlayEntry = OverlayEntry(
//     builder: (context) => Positioned(
//       top: 20,
//       right: 20,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           width: 300, // Optional: Set a width for consistent size
//           height: 100,
//           padding: const EdgeInsets.all(20),
//           margin: const EdgeInsets.only(top: 40, right: 20),
//           decoration: BoxDecoration(
//             color: isError ? Colors.red : Colors.green,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: const [
//               BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
//             ],
//           ),
//           child: AlertMsg(title: title, msg: msg, isError: isError),
//         )
//       ),
//     ), 
//   );
 
//   overlay.insert(overlayEntry);

//   Future.delayed(const Duration(seconds: 3), () {
//     overlayEntry.remove();
//   });
// }
