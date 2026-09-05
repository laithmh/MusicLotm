import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final Settingscontroller settingsController = Get.find<Settingscontroller>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: colorScheme.onPrimary,
        title: Text(
          'Contact & Support',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.inversePrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 48.sp,
                      color: colorScheme.inversePrimary,
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Text(
                        settingsController.appName.value,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Obx(
                      () => Text(
                        'Version ${settingsController.appVersion.value} (${settingsController.appBuildNumber.value})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'We value your feedback and are here to help you with any issues or suggestions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colorScheme.inversePrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Contact Form
            Text(
              'Send Us a Message',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 16.h),

            Form(
              key: settingsController.contactFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: settingsController.nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      labelStyle: TextStyle(
                        color: colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: colorScheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.inversePrimary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    validator: settingsController.validateName,
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: settingsController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      labelStyle: TextStyle(
                        color: colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: colorScheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.inversePrimary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: settingsController.validateEmail,
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: settingsController.messageController,
                    decoration: InputDecoration(
                      labelText: 'Your Message',
                      labelStyle: TextStyle(
                        color: colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: colorScheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.inversePrimary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.message_rounded,
                        color: colorScheme.primary,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: settingsController.validateMessage,
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: settingsController.sendContactEmail,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: colorScheme.inversePrimary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 16.h),

            Column(
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.bug_report,
                  title: 'Report a Bug',
                  subtitle: 'Found an issue? Let us know',
                  color: Colors.red,
                  onTap: () => _showBugReportDialog(context),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Legal & Information',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(height: 16.h),

                _buildActionCard(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  color: colorScheme.primary,
                  onTap: () => settingsController.openUrl(
                    settingsController.privacyPolicyUrl,
                  ),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  color: colorScheme.primary,
                  onTap: () => settingsController.openUrl(
                    settingsController.termsOfServiceUrl,
                  ),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.code_rounded,
                  title: 'GitHub',
                  subtitle: 'View source code',
                  color: colorScheme.primary,
                  onTap: () =>
                      settingsController.openUrl(settingsController.githubUrl),
                ),
              ],
            ),

            SizedBox(height: 28.h),

            // Developer Contact
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        color: colorScheme.inversePrimary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Developer Contact',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Email: ${settingsController.developerEmail}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.inversePrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => settingsController.copyToClipboard(
                      settingsController.developerEmail,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.content_copy_rounded,
                          size: 16.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Copy Email',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.inversePrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'We typically respond within 24-48 hours.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Device Info
            Obx(
              () => Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Information',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.inversePrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final info = await settingsController
                                .getDeviceInfo();
                            settingsController.copyToClipboard(
                              info.toString(),
                            );
                          },
                          child: Icon(
                            Icons.content_copy_rounded,
                            size: 16.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Version: ${settingsController.appVersion.value}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Build: ${settingsController.appBuildNumber.value}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Package: ${settingsController.packageName.value}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Platform: ${GetPlatform.isAndroid ? 'Android' : GetPlatform.isIOS ? 'iOS' : 'Other'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.inversePrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.primary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.sp,
          color: colorScheme.primary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bugDescriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Report a Bug',
          style: TextStyle(
            color: colorScheme.inversePrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please describe the bug you encountered in detail:',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: bugDescriptionController,
                maxLines: 5,
                style: TextStyle(color: colorScheme.inversePrimary),
                decoration: InputDecoration(
                  hintText:
                      'What were you doing when the bug occurred?\nWhat happened?\nWhat did you expect to happen?',
                  hintStyle: TextStyle(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    fontSize: 12.sp,
                  ),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (bugDescriptionController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please describe the bug',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.secondary,
                  colorText: colorScheme.inversePrimary,
                );
                return;
              }

              settingsController.sendErrorReport(bugDescriptionController.text);
              bugDescriptionController.dispose();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.inversePrimary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }
}
