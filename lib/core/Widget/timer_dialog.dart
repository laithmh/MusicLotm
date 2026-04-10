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
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Container(
        constraints: BoxConstraints(maxHeight: 500.h),
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          size: 60.sp,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        SizedBox(height: 20.h),
        Text(
          'Timer Active',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Time remaining:',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: 15.h),
        // Timer display
        Container(
          padding: EdgeInsets.all(20.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha:  0.3),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.inversePrimary,
              width: 2,
            ),
          ),
          child: Text(
            settingscontroller.formattedRemainingTime,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Progress indicator
        LinearProgressIndicator(
          value: _calculateProgress(),
          backgroundColor:
              Theme.of(context).colorScheme.secondary.withValues(alpha:  0.3),
          color: Theme.of(context).colorScheme.inversePrimary,
          minHeight: 8.h,
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
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'HIDE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
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
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('CANCEL'),
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
            color: Theme.of(context).colorScheme.secondary,
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
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withValues(alpha:  0.5),
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
                    duration: Duration(seconds: 2),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick presets
        Text(
          'Quick Settings:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        SizedBox(height: 15.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [5, 10, 15, 30, 45, 60].map((minutes) {
            return ChoiceChip(
              label: Text('${minutes}m'),
              selected: false,
              onSelected: (_) {
                settingscontroller.startTimer(minutes);
                Navigator.of(context).pop();
              },
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withValues(alpha:  0.3),
              selectedColor: Theme.of(context).colorScheme.inversePrimary,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 25.h),
        Divider(
          color: Theme.of(context).colorScheme.secondary,
          thickness: 1,
        ),
        SizedBox(height: 25.h),
        // Custom time
        Text(
          'Custom Time:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
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
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  child: TextField(
                    controller: settingscontroller.hourController,
                    focusNode: _hourFocusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: '00',
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withValues(alpha:  0.5),
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
                SizedBox(height: 5.h),
                Text(
                  'Hours',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 15.w),
            Text(
              ':',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(width: 15.w),
            // Minutes
            Column(
              children: [
                Container(
                  width: 100.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  child: TextField(
                    controller: settingscontroller.minuteController,
                    focusNode: _minuteFocusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: '00',
                      hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withValues(alpha:  0.5),
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
                SizedBox(height: 5.h),
                Text(
                  'Minutes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 30.h),
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
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
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
                      duration: Duration(seconds: 2),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'START',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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