import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';
import 'package:musiclotm/core/Widget/timer_dialog.dart';
import 'package:musiclotm/core/const/routesname.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Settingscontroller settingscontroller = Get.find<Settingscontroller>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Active Sleep Timer Banner
                Obx(() {
                  final isTimerActive =
                      settingscontroller.timerSet.isTrue &&
                      settingscontroller.remainingTime.value > Duration.zero;

                  final remainingTime =
                      settingscontroller.formattedRemainingTime;

                  if (isTimerActive && remainingTime.isNotEmpty) {
                    return Column(
                      children: [
                        Neubox(
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: colorScheme.primary,
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Sleep Timer Active',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.inversePrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  remainingTime,
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.inversePrimary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                LinearProgressIndicator(
                                  value: _calculateProgress(),
                                  backgroundColor:
                                      colorScheme.primary.withValues(alpha: 0.2),
                                  color: colorScheme.primary,
                                  minHeight: 4.h,
                                ),
                                SizedBox(height: 12.h),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    settingscontroller.cancelTimer();
                                  },
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel Timer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 8.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Preferences Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  child: Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                // Dark Mode Tile
                _buildSettingItem(
                  context,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  icon: Icons.dark_mode_outlined,
                  trailing: Obx(
                    () => Switch(
                      activeThumbColor: colorScheme.inversePrimary,
                      value: settingscontroller.isDarkMode.value,
                      onChanged: (value) {
                        settingscontroller.toggleTheme();
                      },
                    ),
                  ),
                ),

                // Sleep Timer Tile
                _buildSettingItem(
                  context,
                  title: 'Sleep Timer',
                  subtitle: 'Automatically pause music after duration',
                  icon: Icons.timer_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TimerDialog(),
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Support Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  child: Text(
                    'Support & Info',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.inversePrimary,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                // Contact Tile
                _buildSettingItem(
                  context,
                  title: 'Contact & Support',
                  subtitle: 'Send feedback or report an issue',
                  icon: Icons.email_outlined,
                  onTap: () {
                    Get.toNamed(Approutes.contact);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Neubox(
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20.sp,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.inversePrimary,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.primary,
                  ),
                )
              : null,
          trailing: trailing ??
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: colorScheme.primary,
              ),
          onTap: onTap,
        ),
      ),
    );
  }

  double _calculateProgress() {
    final remaining = settingscontroller.remainingTime.value;
    final total = Duration(minutes: settingscontroller.time.value);

    if (total.inSeconds == 0) return 0.0;
    return 1.0 - (remaining.inSeconds / total.inSeconds);
  }
}
