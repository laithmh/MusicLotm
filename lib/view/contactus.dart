import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    Settingscontroller controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 5,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.sendEmail();
                },
                child: const Text(
                  'Send',
                  style: TextStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
