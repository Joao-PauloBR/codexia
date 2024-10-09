import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/library_screen.dart';
import 'screens/main_screen.dart';
import 'screens/search_screen.dart';

// ============ App Theme ============
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic),
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        titleLarge: TextStyle(
            fontSize: 22.0, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        titleMedium: TextStyle(
            fontSize: 18.0, fontStyle: FontStyle.italic, fontFamily: 'Roboto'),
        bodyLarge: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
// ============================================================

// ============ Custom Bottom Navigation Bar ============
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final dynamic libraryService;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.libraryService,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(libraryService: libraryService),
            ),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LibraryScreen(libraryService: libraryService),
            ),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchScreen(libraryService: libraryService),
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Biblioteca',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Pesquisar',
        ),
      ],
    );
  }
}
// ============================================================

// ============ Custom Back Button Handler ============
class CustomBackButtonHandler extends StatefulWidget {
  final Widget child;

  const CustomBackButtonHandler({super.key, required this.child});

  @override
  CustomBackButtonHandlerState createState() => CustomBackButtonHandlerState();
}

class CustomBackButtonHandlerState extends State<CustomBackButtonHandler> {
  DateTime? _lastBackPressTime;

  Future<bool> _handlePopRequest() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    } else {
      final now = DateTime.now();
      if (_lastBackPressTime == null ||
          now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pressione "voltar" novamente para sair do aplicativo.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handlePopRequest();
          if (shouldPop) {
            await SystemNavigator.pop();
          }
        }
      },
      child: widget.child,
    );
  }
}
// ============================================================
