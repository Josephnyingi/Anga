import 'package:flutter/material.dart';
import 'web_animations.dart';

/// 🔄 **Web Loading States**
/// 
/// Enhanced loading states optimized for web
class WebLoadingStates {
  // Full screen loading
  static Widget fullScreenLoading({
    String? message,
    Color? color,
  }) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: WebAnimations.fadeIn(
          child: WebLoadingIndicator(
            message: message ?? 'Loading...',
            color: color,
            size: 60,
          ),
        ),
      ),
    );
  }

  // Card loading state
  static Widget cardLoading({
    double? height,
    EdgeInsets? padding,
  }) {
    return WebCard(
      child: Column(
        children: [
          SkeletonLoader(width: double.infinity, height: 20),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 16),
        ],
      ),
    );
  }

  // List loading state
  static Widget listLoading({
    int itemCount = 3,
    double itemHeight = 80,
  }) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SkeletonLoader(
            width: double.infinity,
            height: itemHeight,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Grid loading state
  static Widget gridLoading({
    int crossAxisCount = 2,
    double aspectRatio = 1.0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WebAnimations.fadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WebAnimations.fadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Connection status indicator
class ConnectionStatus extends StatefulWidget {
  final bool isConnected;
  final String? message;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    this.message,
  });

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus>
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
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    if (widget.isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + (_animation.value * 0.5),
                child: const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                  size: 16,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.message ?? 'No internet connection',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
