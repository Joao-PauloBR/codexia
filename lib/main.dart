import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'my_app.dart';
import 'services/library_service.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    logger.e("Error loading .env file", error: e);
  }
  final libraryService = LibraryService();
  runApp(MyApp(libraryService: libraryService));
}
