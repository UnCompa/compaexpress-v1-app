import 'package:compaexpress/widget/windows_wrapped_page.dart';
import 'package:flutter/material.dart';

class CustomWrapperPage<T> extends MaterialPageRoute<T> {
  CustomWrapperPage({
    required WidgetBuilder builder,
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
         settings: settings,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         builder: (context) => WindowWrappedPage(
           title: "CompaExpress",
           child: Builder(builder: builder), // <- aquí ejecutamos el builder
         ),
       );
}
