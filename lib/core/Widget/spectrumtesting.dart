// // lib/controllers/audio_controller.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:get/get.dart';
// import 'package:musiclotm/main.dart';

// class AudioController extends GetxController {
//   final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
//   var spectrumData = <double>[].obs;

//   Future<void> processAudio(String filePath) async {
//     // Replace with appropriate command to extract spectrum data using FFmpeg
//     // This example assumes a hypothetical FFmpeg command for extracting spectrum data
//     String ffmpegCommand =
//         "-i $filePath -lavfi showspectrumpic=s=512x512 -f rawvideo -";
//     var result =
//         await _flutterFFmpeg.executeWithArguments(ffmpegCommand.split(" "));

//     if (result == 0) {
//       // Process the output to get spectrum data
//       // This is a placeholder: actual processing will depend on your specific FFmpeg command and desired data format
//       List<double> data = await _parseSpectrumOutput();
//       spectrumData.assignAll(data);
//     } else {
//       print("Error processing audio");
//     }
//   }

//   Future<List<double>> _parseSpectrumOutput() async {
//     // Placeholder for actual parsing logic
//     return List.generate(512, (index) => index.toDouble());
//   }
// }
// // lib/main.dart

// class Testvisualizer extends StatelessWidget {
//   const Testvisualizer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final AudioController audioController = Get.put(AudioController());
//     return Scaffold(
//       appBar: AppBar(title: const Text('Audio Visualizer')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 String filePath = songHandler.mediaItem.value!
//                     .id; // Update this with the actual file path
//                 await audioController.processAudio(filePath);
//               },
//               child: const Text('Process Audio'),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Obx(() {
//                 return CustomPaint(
//                   painter: SpectrumPainter(audioController.spectrumData),
//                   size: const Size(double.infinity, 200),
//                   willChange: true,
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SpectrumPainter extends CustomPainter {
//   final List<double> spectrumData;

//   SpectrumPainter(this.spectrumData);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     double barWidth = size.width / spectrumData.length;
//     for (int i = 0; i < spectrumData.length; i++) {
//       double barHeight = spectrumData[i];
//       canvas.drawRect(
//         Rect.fromLTWH(
//             i * barWidth, size.height - barHeight, barWidth, barHeight),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
