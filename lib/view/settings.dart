import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Column(
              children: [
                Text(
                  'S E T T I N G S',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // Timer Display
                Obx(() {
                  // Check if timer is active and has remaining time
                  final isTimerActive =
                      settingscontroller.timerSet.isTrue &&
                      settingscontroller.remainingTime.value > Duration.zero;

                  final remainingTime =
                      settingscontroller.formattedRemainingTime;

                  if (isTimerActive && remainingTime.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(15.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:  0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'SLEEP TIMER ACTIVE',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  remainingTime,
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                LinearProgressIndicator(
                                  value: _calculateProgress(),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withValues(alpha:  0.3),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  minHeight: 4.h,
                                ),
                                SizedBox(height: 15.h),
                                ElevatedButton(
                                  onPressed: () {
                                    settingscontroller.cancelTimer();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cancel, size: 18.sp),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'CANCEL TIMER',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),

                SizedBox(height: 12.h),
                const Divider(),

                // Dark Mode
                _buildSettingItem(
                  context,
                  title: 'D A R K  M O D E',
                  icon: Icons.dark_mode_outlined,
                  trailing: Obx(
                    () => Switch(
                      value: settingscontroller.isDarkMode.value,
                      onChanged: (value) {
                        settingscontroller.toggleTheme();
                      },
                    ),
                  ),
                ),

                // Sleep Timer
                _buildSettingItem(
                  context,
                  title: 'S L E E P  T I M E R',
                  icon: Icons.timer_sharp,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TimerDialog(),
                    );
                  },
                ),

                // Contact via Email
                _buildSettingItem(
                  context,
                  title: 'C O N T A C T  V I A  E M A I L',
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
    return Padding(
      padding: EdgeInsets.only(left: 25.w, top: 15.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
        onTap: onTap,
        contentPadding: EdgeInsets.only(right: 20.w),
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
