import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/profile_placeholder_screen.dart';
import '../features/home/presentation/search_placeholder_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const HomeScreen(),
      search: (_) => const SearchPlaceholderScreen(),
      profile: (_) => const ProfilePlaceholderScreen(),
    };
  }
}
