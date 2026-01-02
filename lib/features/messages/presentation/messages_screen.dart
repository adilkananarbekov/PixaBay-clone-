import 'package:flutter/material.dart';

import '../../../core/constants/design_tokens.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Text('Messages', style: headingMedium),
      ),
    );
  }
}
