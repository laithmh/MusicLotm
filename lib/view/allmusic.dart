import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musiclotm/core/Widget/listsongwidget.dart';

class Allmusicscreen extends StatelessWidget {
  const Allmusicscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            "A L L  M U S I C",
            style: TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const SingleChildScrollView(child: Songlistwidget()));
  }
}
