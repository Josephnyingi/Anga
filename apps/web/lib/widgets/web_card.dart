import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// 🃏 **Enhanced Web Card Widget**
/// 
/// Modern card component with web-specific optimizations
class WebCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showHoverEffect;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const WebCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.showHoverEffect = true,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveUtils.getResponsivePadding(context),
      child: Material(
        elevation: elevation ?? 2,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        color: backgroundColor ?? Theme.of(context).cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? Theme.of(context).dividerColor,
                      width: borderWidth ?? 1,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Specialized card for dashboard widgets
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? subtitle;

  const DashboardCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return WebCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

/// Card for displaying metrics/stats
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? valueColor;
  final String? trend;
  final Color? trendColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.valueColor,
    this.trend,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor?.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trend!.startsWith('+') ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: trendColor ?? (trend!.startsWith('+') ? Colors.green : Colors.red),
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: TextStyle(
                    color: trendColor ?? (trend!.startsWith('+') ? Colors.green : Colors.red),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
