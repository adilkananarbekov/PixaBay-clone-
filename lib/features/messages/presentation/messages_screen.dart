import 'package:flutter/material.dart';

import '../../../core/constants/styles.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Text('Messages', style: kHeadingMedium),
      ),
    );
  }
}
