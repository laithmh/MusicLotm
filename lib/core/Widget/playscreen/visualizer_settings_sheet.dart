import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:musiclotm/controller/visualizer_controller.dart';
import 'package:musiclotm/core/Widget/neubox.dart';

class VisualizerSettingsSheet extends StatelessWidget {
  final bool isInline;
  final VoidCallback? onClose;

  const VisualizerSettingsSheet({
    super.key,
    this.isInline = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final VisualizerController controller = Get.find<VisualizerController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // App theme colors
    final Color backgroundColor = colorScheme.onPrimary; // Deep charcoal in dark mode, soft grey in light
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.grey.shade900;
    final Color secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color accentColor = isDarkMode ? Colors.white : Colors.grey.shade900;

    return Container(
      constraints: isInline
          ? null
          : BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.68,
            ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: isInline
            ? BorderRadius.circular(24.r)
            : BorderRadius.vertical(top: Radius.circular(28.r)),
        border: isInline
            ? Border.all(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400,
                width: 1.0,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.8) : Colors.grey.shade600,
            blurRadius: isInline ? 8 : 16,
            offset: isInline ? const Offset(2, 2) : const Offset(0, -6),
          ),
          if (isInline)
            BoxShadow(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: isInline ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // 1. Drag Handle (only when modal)
            if (!isInline)
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, isInline ? 16.h : 8.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Header Row
                    Row(
                      children: [
                        // Left: Icon + Title (Flexible)
                        Expanded(
                          child: Row(
                            children: [
                              Neubox(
                                borderRadius: BorderRadius.circular(10.r),
                                height: 36.h,
                                width: 36.h,
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: primaryTextColor,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STUDIO',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      'Real-time tuning',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Right: Action Buttons (RESET & DONE)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.resetDefaults();
                              },
                              child: Neubox(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 13.sp,
                                        color: primaryTextColor,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'RESET',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryTextColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (isInline) ...[
                              SizedBox(width: 6.w),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  controller.saveSettingsNow();
                                  if (onClose != null) {
                                    onClose!();
                                  } else {
                                    controller.isStudioOpen.value = false;
                                  }
                                },
                                child: Neubox(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          size: 14.sp,
                                          color: primaryTextColor,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'DONE',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: primaryTextColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // 3. Style Selector
                    Text(
                      'STYLE',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(() {
                      final currentStyle = controller.currentStyle.value;
                      return SizedBox(
                        height: 60.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _NeumorphicStyleCard(
                              title: 'RADIAL BARS',
                              subtitle: 'Trap Nation punchy',
                              icon: Icons.graphic_eq_rounded,
                              isSelected: currentStyle == VisualizerStyle.radialBars,
                              isDarkMode: isDarkMode,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.currentStyle.value = VisualizerStyle.radialBars;
                              },
                            ),
                            SizedBox(width: 10.w),
                            _NeumorphicStyleCard(
                              title: 'LIQUID WAVE',
                              subtitle: 'Neumorphic fluid',
                              icon: Icons.waves_rounded,
                              isSelected: currentStyle == VisualizerStyle.liquid,
                              isDarkMode: isDarkMode,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.currentStyle.value = VisualizerStyle.liquid;
                              },
                            ),
                            SizedBox(width: 10.w),
                            _NeumorphicStyleCard(
                              title: 'ECLIPSE NOVA',
                              subtitle: 'Corona & peak embers',
                              icon: Icons.flare_rounded,
                              isSelected: currentStyle == VisualizerStyle.eclipseNova,
                              isDarkMode: isDarkMode,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.currentStyle.value = VisualizerStyle.eclipseNova;
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 24.h),

                    // 4. Sliders Section
                    Text(
                      'BALLISTICS & DYNAMICS',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Sensitivity / Gamma
                    Obx(() => _NeumorphicSliderTile(
                          title: 'Sensitivity / Gamma',
                          subtitle: 'Contrast curve & quiet detail boost',
                          valueDisplay: '${controller.sensitivityGamma.value.toStringAsFixed(2)}x',
                          value: controller.sensitivityGamma.value,
                          min: 0.8,
                          max: 2.5,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          accentColor: accentColor,
                          onChanged: (val) => controller.sensitivityGamma.value = val,
                        )),
                    SizedBox(height: 14.h),

                    // Transient Attack
                    Obx(() => _NeumorphicSliderTile(
                          title: 'Transient Attack Speed',
                          subtitle: 'Rise speed when beat hits (snappy vs soft)',
                          valueDisplay: controller.attack.value.toStringAsFixed(2),
                          value: controller.attack.value,
                          min: 0.20,
                          max: 0.95,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          accentColor: accentColor,
                          onChanged: (val) => controller.attack.value = val,
                        )),
                    SizedBox(height: 14.h),

                    // Gravity Decay
                    Obx(() => _NeumorphicSliderTile(
                          title: 'Gravity Decay',
                          subtitle: 'Falloff smoothness (bouncy vs lingering)',
                          valueDisplay: controller.decay.value.toStringAsFixed(2),
                          value: controller.decay.value,
                          min: 0.60,
                          max: 0.92,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          accentColor: accentColor,
                          onChanged: (val) => controller.decay.value = val,
                        )),
                    SizedBox(height: 14.h),

                    // Amplitude Height
                    Obx(() => _NeumorphicSliderTile(
                          title: 'Max Amplitude Height',
                          subtitle: 'Maximum bar/wave radial projection',
                          valueDisplay: '${controller.maxHeight.value.round()} px',
                          value: controller.maxHeight.value,
                          min: 15.0,
                          max: 60.0,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          accentColor: accentColor,
                          onChanged: (val) => controller.maxHeight.value = val,
                        )),
                    SizedBox(height: 14.h),

                    // Disk Pulse Animation Toggle
                    Obx(() => _NeumorphicToggleTile(
                          title: 'Disk Pulse Animation',
                          subtitle: 'Bounce album disk with music kicks and 808s',
                          value: controller.enableDiskAnimation.value,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            controller.enableDiskAnimation.value = val;
                          },
                        )),
                    SizedBox(height: 14.h),

                    // Kick Bass Pump
                    Obx(() => _NeumorphicSliderTile(
                          title: 'Kick Bass Pump',
                          subtitle: 'Album art bounce on 808 & sub-bass hits',
                          valueDisplay: '${(controller.kickScale.value * 100).round()}%',
                          value: controller.kickScale.value,
                          min: 0.00,
                          max: 0.15,
                          isDarkMode: isDarkMode,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          accentColor: accentColor,
                          onChanged: (val) => controller.kickScale.value = val,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicStyleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDarkMode;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _NeumorphicStyleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDarkMode,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 155.w,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)
              : Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? Colors.white70 : Colors.black87)
                : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black : Colors.grey.shade600,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryTextColor
                  : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
              size: 26.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryTextColor : secondaryTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isSelected
                          ? secondaryTextColor
                          : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicSliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String valueDisplay;
  final double value;
  final double min;
  final double max;
  final bool isDarkMode;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  const _NeumorphicSliderTile({
    required this.title,
    required this.subtitle,
    required this.valueDisplay,
    required this.value,
    required this.min,
    required this.max,
    required this.isDarkMode,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800.withValues(alpha: 0.6) : Colors.grey.shade400.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.grey.shade500,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: isDarkMode ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.white,
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Neubox(
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  child: Text(
                    valueDisplay,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.h,
              activeTrackColor: isDarkMode ? Colors.white : Colors.grey.shade900,
              inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400,
              thumbColor: isDarkMode ? Colors.white : Colors.grey.shade900,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
              overlayColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.15),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeumorphicToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isDarkMode;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final ValueChanged<bool> onChanged;

  const _NeumorphicToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDarkMode,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey.shade800.withValues(alpha: 0.6)
                : Colors.grey.shade400.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.grey.shade500,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.white,
              blurRadius: 5,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Neubox(
              borderRadius: BorderRadius.circular(10.r),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  value ? Icons.motion_photos_on_rounded : Icons.motion_photos_off_rounded,
                  size: 18.sp,
                  color: value
                      ? primaryTextColor
                      : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            // High-Contrast Neumorphic Sliding Pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50.w,
              height: 28.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: value
                    ? (isDarkMode ? Colors.white : Colors.grey.shade900)
                    : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.grey.shade600,
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22.h,
                  height: 22.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? (isDarkMode ? Colors.grey.shade900 : Colors.white)
                        : (isDarkMode ? Colors.grey.shade400 : Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      value ? Icons.check_rounded : Icons.close_rounded,
                      size: 13.sp,
                      color: value
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
