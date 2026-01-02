import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/styles.dart';
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
      scaffoldBackgroundColor: kBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: kPrimaryColor,
        secondary: kSecondaryRed,
        surface: kCardColor,
        onPrimary: kWhite,
        onSurface: kWhite,
      ),
      textTheme: const TextTheme(
        headlineLarge: kHeadingLarge,
        headlineMedium: kHeadingMedium,
        bodyLarge: kBodyRegular,
        bodyMedium: kBodyRegular,
        bodySmall: kCaption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: kBackgroundColor,
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
