import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codexia/my_app.dart';
import 'package:codexia/services/library_service.dart';

class MockLibraryService extends LibraryService {
  // Implemente métodos ou propriedades mockadas, se necessário
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Criar uma instância mock do LibraryService
    final mockLibraryService = MockLibraryService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(libraryService: mockLibraryService));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
