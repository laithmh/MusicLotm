import 'package:flutter/material.dart';

import 'package:musiclotm/core/Widget/neubox.dart';




class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextField(
                onChanged: (value) {},
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "search"),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount:null,
                itemBuilder: (BuildContext context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(7),
                    child: Neubox(
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        title: const Text(""),
                        subtitle: const Text(
                            ""),
                        leading:  const Icon(Icons.music_note),
                        
                        onTap: () {
                         
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
