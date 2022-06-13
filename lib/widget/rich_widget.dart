// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';

/// Widget wrapper to use RichText
class RichWidget extends StatelessWidget {
  final String? firstText;
  final List<TextSpan>? children;
  RichWidget({this.firstText, this.children});
  @override
  Widget build(BuildContext context) {
    return RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textAlign: DefaultTextStyle.of(context).textAlign ?? TextAlign.start,
      text: TextSpan(
        text: firstText,
        style: DefaultTextStyle.of(context).style,
        children: children,
      ),
    );
  }
}
