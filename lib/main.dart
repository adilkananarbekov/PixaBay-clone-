import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/design_tokens.dart';
import 'features/navigation/presentation/navigation_shell.dart';

void main() {
  runApp(const ProviderScope(child: PixabayApp()));
}

class PixabayApp extends StatelessWidget {
  const PixabayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryRed,
        surface: cardColor,
        onPrimary: white,
        onSurface: white,
      ),
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        bodyLarge: bodyRegular,
        bodyMedium: bodyRegular,
        bodySmall: caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: backgroundColor,
        elevation: 0,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pixabay Pinterest Redesign',
      theme: theme,
      home: const NavigationShell(),
    );
  }
}
