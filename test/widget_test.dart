import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qhack_picnic/main.dart';

void main() {
  testWidgets('discover screen boots and tabs switch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(startOnSmartBasket: false));
    await tester.pumpAndSettle();

    expect(find.text('Smart Basket (1 Tap)'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Favoriten'));
    await tester.pumpAndSettle();
    expect(find.text('Favoriten'), findsWidgets);

    await tester.tap(find.text('Suchen'));
    await tester.pumpAndSettle();
    expect(find.text('Suchen'), findsWidgets);
  });
}
