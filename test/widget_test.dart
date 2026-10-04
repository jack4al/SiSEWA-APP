import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sisewa/core/database/app_database.dart';
import 'package:sisewa/core/database/database_provider.dart';
import 'package:sisewa/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const SisewaApp(),
      ),
    );
    expect(find.byType(SisewaApp), findsOneWidget);
  });
}
