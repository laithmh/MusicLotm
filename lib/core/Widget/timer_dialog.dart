import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/settingscontroller.dart';

class TimerDialog extends StatefulWidget {
  const TimerDialog({super.key});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  final Settingscontroller settingscontroller = Get.find<Settingscontroller>();
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();

  @override
  void dispose() {
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        constraints: BoxConstraints(maxHeight: 520.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Center(
                child: Text(
                  'SLEEP TIMER',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.h),
                  child: Obx(() {
                    if (settingscontroller.timerSet.isTrue &&
                        settingscontroller.remainingTime.value > Duration.zero) {
                      return _buildActiveTimerView(context);
                    } else {
                      return _buildTimerSetupView(context);
                    }
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimerView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          size: 60.sp,
          color: colorScheme.inversePrimary,
        ),
        SizedBox(height: 20.h),
        Text(
          'Timer Active',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Time remaining:',
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 15.h),
        // Timer display
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: colorScheme.inversePrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            settingscontroller.formattedRemainingTime,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.inversePrimary,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Progress indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: colorScheme.secondary,
            color: colorScheme.inversePrimary,
            minHeight: 8.h,
          ),
        ),
        SizedBox(height: 20.h),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.primary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'HIDE',
                  style: TextStyle(
                    color: colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  settingscontroller.cancelTimer();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        // Add time options
        Text(
          'Add more time:',
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [5, 10, 15, 30].map((minutes) {
            return ActionChip(
              label: Text(
                '+$minutes min',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inversePrimary,
                ),
              ),
              backgroundColor: colorScheme.secondary,
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              onPressed: () {
                final currentEndTime = settingscontroller.timerEndTime.value;
                if (currentEndTime != null) {
                  final newEndTime =
                      currentEndTime.add(Duration(minutes: minutes));
                  settingscontroller.timerEndTime.value = newEndTime;
                  settingscontroller.remainingTime.value =
                      newEndTime.difference(DateTime.now());
                  Get.snackbar(
                    'Time Added',
                    'Added $minutes minutes',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    backgroundColor: colorScheme.secondary,
                    colorText: colorScheme.inversePrimary,
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimerSetupView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick presets
        Text(
          'Quick Presets',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 15.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [5, 10, 15, 30, 45, 60].map((minutes) {
            return ActionChip(
              label: Text(
                '${minutes}m',
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                settingscontroller.startTimer(minutes);
                Navigator.of(context).pop();
              },
              backgroundColor: colorScheme.secondary,
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
        Divider(
          color: colorScheme.primary.withValues(alpha: 0.3),
          thickness: 1,
        ),
        SizedBox(height: 15.h),
        // Custom time
        Text(
          'Custom Time',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours
            Column(
              children: [
                Container(
                  width: 100.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: settingscontroller.hourController,
                      focusNode: _hourFocusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.inversePrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onTapOutside: (_) {
                        _hourFocusNode.unfocus();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Hours',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.inversePrimary,
                ),
              ),
            ),
            // Minutes
            Column(
              children: [
                Container(
                  width: 100.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: settingscontroller.minuteController,
                      focusNode: _minuteFocusNode,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.inversePrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onTapOutside: (_) {
                        _minuteFocusNode.unfocus();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Minutes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 25.h),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  settingscontroller.clearTimerForm();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.primary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final minutes = settingscontroller.setTimer();
                  if (minutes > 0) {
                    settingscontroller.startTimer(minutes);
                    settingscontroller.clearTimerForm();
                    Navigator.of(context).pop();
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid time',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      backgroundColor: colorScheme.secondary,
                      colorText: colorScheme.inversePrimary,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.inversePrimary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateProgress() {
    final remaining = settingscontroller.remainingTime.value;
    final total = Duration(minutes: settingscontroller.totalMinutesSet.value);
    
    if (total.inSeconds == 0) return 0.0;
    return 1.0 - (remaining.inSeconds / total.inSeconds);
  }
}