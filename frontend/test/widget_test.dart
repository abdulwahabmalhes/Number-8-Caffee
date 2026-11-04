import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('NUMBER EIGHT App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NumberEightApp()));
    expect(find.text('اطلب من طاولتك مباشرة'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });
}
