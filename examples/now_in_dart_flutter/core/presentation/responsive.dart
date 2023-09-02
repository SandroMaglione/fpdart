import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  const Responsive({
    required this.mobile,
    required this.tabletOrDesktop,
    super.key,
  });

  final Widget mobile, tabletOrDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return mobile;
        } else {
          return tabletOrDesktop;
        }
      },
    );
  }
}
