import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final Settingscontroller settingsController = Get.find<Settingscontroller>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          'CONTACT & SUPPORT',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 50.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Text(
                        settingsController.appName.value,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => Text(
                        'Version ${settingsController.appVersion.value} (${settingsController.appBuildNumber.value})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'We value your feedback and are here to help you with any issues or suggestions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSecondary,
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
                color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    validator: settingsController.validateName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: settingsController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: settingsController.validateEmail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: settingsController.messageController,
                    decoration: InputDecoration(
                      labelText: 'Your Message',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.message,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: settingsController.validateMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: settingsController.sendContactEmail,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
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

            SizedBox(height: 32.h),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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

                // _buildActionCard(
                //   context,
                //   icon: Icons.share,
                //   title: 'Share App',
                //   subtitle: 'Share with friends',
                //   color: Colors.green,
                //   onTap: settingsController.shareApp,
                // ),

                // _buildActionCard(
                //   context,
                //   icon: Icons.star,
                //   title: 'Rate App',
                //   subtitle: 'Rate us on app store',
                //   color: Colors.amber,
                //   onTap: settingsController.rateApp,
                // ),

                SizedBox(height: 24.h),

                Text(
                  'Legal & Information',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),

                _buildActionCard(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  color: Colors.blue,
                  onTap: () => settingsController.openUrl(
                    settingsController.privacyPolicyUrl,
                  ),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.description,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  color: Colors.purple,
                  onTap: () => settingsController.openUrl(
                    settingsController.termsOfServiceUrl,
                  ),
                ),

                _buildActionCard(
                  context,
                  icon: Icons.code,
                  title: 'GitHub',
                  subtitle: 'View source code',
                  color: Colors.grey,
                  onTap: () =>
                      settingsController.openUrl(settingsController.githubUrl),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Developer Contact
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Developer Contact',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Email: ${settingsController.developerEmail}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSecondary,
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
                            Icons.content_copy,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Copy Email',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Device Info (Optional - for debugging)
            Obx(
              () => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.5),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
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
                              color: Theme.of(context).colorScheme.primary,
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
                              Icons.content_copy,
                              size: 16.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Version: ${settingsController.appVersion.value}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      Text(
                        'Build: ${settingsController.appBuildNumber.value}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      Text(
                        'Package: ${settingsController.packageName.value}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      Text(
                        'Platform: ${GetPlatform.isAndroid
                            ? 'Android'
                            : GetPlatform.isIOS
                            ? 'iOS'
                            : 'Other'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
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
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final bugDescriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Report a Bug',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please describe the bug you encountered in detail:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: bugDescriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'What were you doing when the bug occurred?\nWhat happened?\nWhat did you expect to happen?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
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
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (bugDescriptionController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please describe the bug',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              settingsController.sendErrorReport(bugDescriptionController.text);
              bugDescriptionController.dispose();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('Send Report'),
          ),
        ],
      ),
    );
  }
}
