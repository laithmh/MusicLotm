import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:musiclotm/controller/notifiers/songs_provider.dart';
import 'package:musiclotm/core/Widget/customaudioimage.dart';
import 'package:musiclotm/core/Widget/customplaybutton.dart';
import 'package:musiclotm/core/Widget/playscreen/addplaylistbutton.dart';
import 'package:musiclotm/core/Widget/waveformwidget.dart';



class Playscreen extends StatelessWidget {
  const Playscreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
   

    return FutureBuilder(
        future: Future.wait([
          
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  title: Text(
                    "P L A Y",
                    style:
                        TextStyle(fontSize: 75.sp, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                body: GetBuilder<Songscontroller>(
                  builder: (controller) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, bottom: 25, top: 10),
                      child: Column(
                        children: [
                         const Customaudioimage(
                                id: 1,
                                artestname: "",
                                musicname: "",
                                 ),
                          
                          SizedBox(
                            height: 25.h,
                          ),
                          const Addtoplaylistbutton(),
                          const PolygonWaveformcustom(
                            max: 12,
                            value: 1,
                            
                          ),
                          SizedBox(
                            height: 50.h,
                          ),
                          const Customplaybutton(),
                        ],
                      ),
                    );
                  },
                ));
          }
        });
  }
}
