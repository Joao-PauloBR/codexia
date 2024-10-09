import 'package:flutter/material.dart';
import 'services/library_service.dart';
import 'screens/main_screen.dart';
import 'global_wrapper.dart';

class MyApp extends StatelessWidget {
  final LibraryService libraryService;

  const MyApp({super.key, required this.libraryService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Books',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainScreen(libraryService: libraryService),
    );
  }
}
