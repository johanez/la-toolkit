import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

import '../laTheme.dart';

class FormattedTitle extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final double? fontSize;
  final Color? color;

  const FormattedTitle(
      {Key? key, required this.title, this.fontSize, this.color, this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(StringUtils.capitalize(title),
            style: GoogleFonts.signika(
                textStyle: TextStyle(
                    color: color ?? LAColorTheme.laPalette.shade500,
                    fontSize: fontSize ?? 18,
                    fontWeight: FontWeight.w400))),
        subtitle: subtitle);
  }
}
