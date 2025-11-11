// navigation_utils.dart
import 'package:compaexpress/widget/windows_wrapped_page.dart';
import 'package:flutter/material.dart';

Future<T?> pushWrapped<T>(BuildContext context, Widget page, {String? title}) {
  return Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (_) => WindowWrappedPage(title: title, child: page),
    ),
  );
}
