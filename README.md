# Pixabay Pinterest Redesign

## Overview
A Pinterest-style image feed built on the Pixabay API with a dark theme and layouts matching the Figma redesign. The app demonstrates Dio networking, Riverpod state management, and a custom icon font.

## Features
- Bottom navigation with four tabs and a central floating plus button
- Explore and For you feeds using a masonry grid layout
- Boards grid with collage cards and metadata
- Board detail screen with collaborators, categories, sub-boards, and pin grid
- Pin detail screen with hero image, sponsor row, similar pins, and load more
- Infinite scrolling when approaching the end of lists
- Skeleton placeholders and cached image loading
- UI-only controls for search, filters, and actions

## Tech stack
- Flutter
- Riverpod 2 (StateNotifier)
- Dio
- cached_network_image
- flutter_staggered_grid_view

## Architecture
- Core layer for constants and network setup
- Data layer for Pixabay API access and repository abstraction
- Feature layer for navigation, feeds, boards, board detail, and pin detail

## Project structure
lib/
  core/
    constants/
    network/
  data/
    models/
    datasources/
    repositories/
  features/
    navigation/
    feed/
    boards/
    board_detail/
    pin_detail/
    messages/
    profile/
  main.dart

## API integration
The Pixabay API key is injected via dart-define:

flutter run --dart-define=PIXABAY_API_KEY=YOUR_API_KEY

Requests include:
- key
- image_type=photo
- orientation=vertical
- safesearch=true
- page and per_page=20

## Design and styling
All colors, spacing, radii, and text styles are centralized in `lib/core/constants/styles.dart`. Custom SVG icons are converted into a font and mapped in `lib/core/constants/app_icons.dart`.

## Limitations
- Search and filtering are UI-only (no query logic)
- Save, share, and menu actions are not implemented
- Error handling is minimal

## Possible improvements
- Add retry and empty states
- Add unit and widget tests for state notifiers and screens
- Improve offline caching and preload strategy
