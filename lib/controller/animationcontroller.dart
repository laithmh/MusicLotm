import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimationControllerX extends GetxController with GetTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _animationController;
  
  RxBool isAnimating = false.obs;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    
    // Rotation controller for continuous animations (like album art rotation)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Adjusted for realistic rotation speed
    )..repeat();

    // Main animation controller for UI transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut, 
      parent: _animationController
    );
    
    animation = Tween<double>(
      begin: 0.0, 
      end: 1.0
    ).animate(curvedAnimation);
    
    // Initialize in stopped state
    stop();
  }

  // Start rotation animation
  void start() {
    if (!_rotationController.isAnimating) {
      _rotationController.repeat();
    }
    isAnimating.value = true;
  }

  // Stop rotation animation
  void stop() {
    _rotationController.stop();
    isAnimating.value = false;
  }

  // Reset rotation to beginning
  void reset() {
    _rotationController.reset();
  }

  // Toggle the secondary animation
  void toggleAnimation() {
    if (_animationController.isAnimating) {
      // If currently animating, don't interrupt
      return;
    }
    
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  // Forward animation
  void forwardAnimation() {
    if (_animationController.status != AnimationStatus.forward) {
      _animationController.forward();
    }
  }

  // Reverse animation
  void reverseAnimation() {
    if (_animationController.status != AnimationStatus.reverse) {
      _animationController.reverse();
    }
  }

  // Complete animation immediately
  void completeAnimation() {
    _animationController.animateTo(1.0, duration: Duration.zero);
  }

  // Reset animation to beginning
  void resetAnimation() {
    _animationController.animateTo(0.0, duration: Duration.zero);
  }

  // Set custom rotation speed
  void setRotationSpeed(double seconds) {
    _rotationController.duration = Duration(seconds: seconds.toInt());
    // Restart the animation with new duration if currently running
    if (isAnimating.value) {
      _rotationController.repeat();
    }
  }

  // Get current rotation progress
  double get rotationProgress => _rotationController.value;

  // Get current animation progress
  double get animationProgress => animation.value;

  // Check if rotation is currently running
  bool get isRotationActive => _rotationController.isAnimating;

  // Check if secondary animation is running
  bool get isSecondaryAnimationActive => 
      _animationController.status == AnimationStatus.forward || 
      _animationController.status == AnimationStatus.reverse;

  // Smooth transition between states
  Future<void> animateToState(bool shouldAnimate) async {
    if (shouldAnimate) {
      start();
    } else {
      stop();
    }
  }

  // Dispose controllers properly
  @override
  void onClose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.onClose();
  }

  // Additional utility methods for animation control
  void restartAnimation() {
    resetAnimation();
    Future.delayed(const Duration(milliseconds: 100), () {
      forwardAnimation();
    });
  }

  // Method to sync both animations
  void syncAnimations() {
    if (isAnimating.value) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }
}