import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Neubox extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final bool? index;
  const Neubox(
      {super.key, required this.child, required this.borderRadius, this.index});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: index ?? false
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.background,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
              color: isDarkMode ? Colors.black : Colors.grey.shade600,
              blurRadius: 5,
              offset: const Offset(2, 2),
              spreadRadius: 0),
          BoxShadow(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              blurRadius: 5,
              offset: const Offset(-2, -2),
              spreadRadius: 0)
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: child,
    );
  }
}
