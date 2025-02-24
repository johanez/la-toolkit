import 'package:flutter/material.dart';

class ShadowIcon extends StatelessWidget {
  const ShadowIcon(
      {Key? key, required this.icon, required this.size, required this.color})
      : super(key: key);

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size),
        ),
        child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size, color: color)));
  }
}
