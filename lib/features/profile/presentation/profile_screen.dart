import 'package:flutter/material.dart';

import '../../../core/constants/design_tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Text('Profile', style: headingMedium),
      ),
    );
  }
}
