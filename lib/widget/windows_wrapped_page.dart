import 'package:compaexpress/widget/custom_window_title_bar.dart';
import 'package:flutter/material.dart';

class WindowWrappedPage extends StatelessWidget {
  final Widget child;
  final String? title;

  const WindowWrappedPage({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final screenTitle = 'CompaExpress';

    return CustomWindowTitleBar(title: screenTitle, child: child);
  }
}
