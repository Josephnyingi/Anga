import 'package:flutter/material.dart';

/// ✨ **Web-Specific Animations**
/// 
/// Smooth animations optimized for web performance
class WebAnimations {
  // Page transition animations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * 50,
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = normalDuration,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = normalDuration,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: Duration(
            milliseconds: itemDuration.inMilliseconds + (index * staggerDelay.inMilliseconds),
          ),
          curve: Curves.easeOut,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 30),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

/// Animated loading indicator
class WebLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const WebLoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40,
  });

  @override
  State<WebLoadingIndicator> createState() => _WebLoadingIndicatorState();
}

class _WebLoadingIndicatorState extends State<WebLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                    widget.color ?? Theme.of(context).primaryColor,
                    (widget.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  ],
                  stops: [
                    _animation.value - 0.1,
                    _animation.value,
                    _animation.value + 0.1,
                  ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: widget.size * 0.4,
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Skeleton loading widget
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value * 0.3),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

/// Pulse animation for buttons
class PulseButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;

  const PulseButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enabled ? _animation.value : 1.0,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.6,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
