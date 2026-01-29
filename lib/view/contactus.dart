// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ContactUs extends ConsumerStatefulWidget {
//   const ContactUs({super.key});

//   @override
//   ConsumerState<ContactUs> createState() => _ContactUsState();
// }

// class _ContactUsState extends ConsumerState<ContactUs> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _messageController;

//   @override
//   void initState() {
//     super.initState();
//     _messageController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contactUsState = ref.watch(contactUsProvider);
//     final contactUsNotifier = ref.watch(contactUsProvider.notifier);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Contact Us'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _messageController,
//                 decoration: const InputDecoration(labelText: 'Message'),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your message';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: contactUsState.isLoading
//                     ? null
//                     : () {
//                         if (_formKey.currentState?.validate() ?? false) {
//                           contactUsNotifier.sendEmail(_messageController.text);
//                         }
//                       },
//                 child: contactUsState.isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text('Send'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }