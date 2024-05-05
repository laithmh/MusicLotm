import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Customappbar extends StatelessWidget {
  const Customappbar({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Text(
                        "P L A Y",
                        style: TextStyle(fontSize: 30),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
                    ],
                  );
  }
}