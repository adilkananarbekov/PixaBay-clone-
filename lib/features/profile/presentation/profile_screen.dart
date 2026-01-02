import 'package:flutter/material.dart';

import '../../../core/constants/styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Text('Profile', style: kHeadingMedium),
      ),
    );
  }
}
