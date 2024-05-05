import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class Floatingbuttonwidget extends StatelessWidget {
  const Floatingbuttonwidget({super.key});

  @override
  Widget build(BuildContext context) {
    

    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: SizedBox(
              height: 800.h,
              child: Column(
                children: [
                  const TextField(
                    controller:null,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "add new playlist"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: () {
                         
                        },
                        child: const Text("save"),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("cancel"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      
    );
  }
}
