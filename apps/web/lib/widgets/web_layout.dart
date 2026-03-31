import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'web_navigation.dart';

/// 🏗️ **Web Layout Components**
/// 
/// Advanced layout components optimized for web
class WebLayout extends StatelessWidget {
  final Widget child;
  final List<NavigationItem>? navigationItems;
  final int? selectedNavIndex;
  final Function(int)? onNavItemSelected;
  final Widget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showNavigation;
  final bool showBreadcrumb;
  final List<BreadcrumbItem>? breadcrumbItems;
  final Function(int)? onBreadcrumbTap;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const WebLayout({
    super.key,
    required this.child,
    this.navigationItems,
    this.selectedNavIndex,
    this.onNavItemSelected,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.showNavigation = true,
    this.showBreadcrumb = false,
    this.breadcrumbItems,
    this.onBreadcrumbTap,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
        largeDesktop: _buildLargeDesktopLayout(context),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        if (showBreadcrumb && breadcrumbItems != null)
          WebNavigation.breadcrumb(
            items: breadcrumbItems!,
            onItemTap: onBreadcrumbTap ?? (index) {},
          ),
        Expanded(child: child),
        if (showNavigation && navigationItems != null)
          WebNavigation.bottomNavigation(
            items: navigationItems!,
            selectedIndex: selectedNavIndex ?? 0,
            onItemSelected: onNavItemSelected ?? (index) {},
          ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        if (showNavigation && navigationItems != null)
          SizedBox(
            width: 200,
            child: WebNavigation.sideNavigation(
              items: navigationItems!,
              selectedIndex: selectedNavIndex ?? 0,
              onItemSelected: onNavItemSelected ?? (index) {},
              isCollapsed: false,
            ),
          ),
        Expanded(
          child: Column(
            children: [
              if (showBreadcrumb && breadcrumbItems != null)
                WebNavigation.breadcrumb(
                  items: breadcrumbItems!,
                  onItemTap: onBreadcrumbTap ?? (index) {},
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        if (showNavigation && navigationItems != null)
          SizedBox(
            width: 280,
            child: WebNavigation.sideNavigation(
              items: navigationItems!,
              selectedIndex: selectedNavIndex ?? 0,
              onItemSelected: onNavItemSelected ?? (index) {},
              isCollapsed: false,
            ),
          ),
        Expanded(
          child: Column(
            children: [
              if (showBreadcrumb && breadcrumbItems != null)
                WebNavigation.breadcrumb(
                  items: breadcrumbItems!,
                  onItemTap: onBreadcrumbTap ?? (index) {},
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeDesktopLayout(BuildContext context) {
    return Row(
      children: [
        if (showNavigation && navigationItems != null)
          SizedBox(
            width: 320,
            child: WebNavigation.sideNavigation(
              items: navigationItems!,
              selectedIndex: selectedNavIndex ?? 0,
              onItemSelected: onNavItemSelected ?? (index) {},
              isCollapsed: false,
            ),
          ),
        Expanded(
          child: Column(
            children: [
              if (showBreadcrumb && breadcrumbItems != null)
                WebNavigation.breadcrumb(
                  items: breadcrumbItems!,
                  onItemTap: onBreadcrumbTap ?? (index) {},
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

/// Grid layout with responsive columns
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? maxCrossAxisCount;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.maxCrossAxisCount,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = maxCrossAxisCount ?? 
            ResponsiveUtils.getResponsiveColumns(context);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Staggered grid layout
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? maxCrossAxisCount;

  const StaggeredGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.maxCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = maxCrossAxisCount ?? 
            ResponsiveUtils.getResponsiveColumns(context);
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Masonry layout for cards
class MasonryLayout extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int? crossAxisCount;

  const MasonryLayout({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = crossAxisCount ?? ResponsiveUtils.getResponsiveColumns(context);
        final columnWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        
        final List<List<Widget>> columnChildren = List.generate(columns, (_) => []);
        final List<double> columnHeights = List.generate(columns, (_) => 0.0);
        
        for (final child in children) {
          final shortestColumn = columnHeights.indexOf(columnHeights.reduce((a, b) => a < b ? a : b));
          columnChildren[shortestColumn].add(child);
          columnHeights[shortestColumn] += 200; // Approximate height
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columns, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < columns - 1 ? spacing : 0,
                ),
                child: Column(
                  children: columnChildren[index],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
