import 'package:flutter/material.dart';

import 'dart:io';

class RefreshableLayout extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshableLayout({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // For iOS, we often use CustomScrollView with CupertinoSliverRefreshControl.
      // However, if the child is already a scrollable widget (like ListView or SingleChildScrollView),
      // wrapping it in another scroll view might cause conflict unless we use Slivers.
      // To keep it simple and compatible with existing non-sliver children,
      // we can use RefreshIndicator which works on iOS too (Material style),
      // OR we can try to use a CustomScrollView if the child allows it.

      // Given the requirement to "wrap" existing content which might be a Column in a SingleChildScrollView,
      // the safest cross-platform approach without refactoring everything to Slivers is RefreshIndicator.
      // It provides a decent UX on iOS as well (spinner at top).

      // If we want true iOS style, we'd need to ensure 'child' is a Sliver or put it in a SliverToBoxAdapter
      // inside a CustomScrollView. That might be too invasive for a "wrapper".

      // Let's stick to RefreshIndicator for now as per the plan note,
      // but style it if possible.
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: Colors.black, // Customize as needed
        backgroundColor: Colors.white,
        child: child,
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: child,
      );
    }
  }
}
