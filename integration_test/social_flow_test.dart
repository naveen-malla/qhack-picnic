import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:qhack_picnic/main.dart' as app;
import 'package:qhack_picnic/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('social feed adds recipe and challenge items into the cart', (
    WidgetTester tester,
  ) async {
    wishlistStore.clear();
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Social'));
    await tester.pumpAndSettle();

    expect(find.text('Tomaten-Reis-Bowl'), findsWidgets);
    await binding.takeScreenshot('social-feed-top');

    await tester.tap(find.byKey(const Key('socialRecipeFlipArea')));
    await tester.pumpAndSettle();
    expect(find.text('Zutaten'), findsOneWidget);
    expect(wishlistStore.qtyById, isEmpty);

    await tester.tap(find.byKey(const Key('socialRecipeAddButton')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('socialChallengeJoinButton')),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 saisonale Gemüse bis Sonntag'), findsOneWidget);
    await binding.takeScreenshot('social-feed-challenge');

    await tester.tap(find.byKey(const Key('socialChallengeJoinButton')));
    await tester.pumpAndSettle();
    expect(find.text('Du bist dabei'), findsOneWidget);

    await tester.tap(find.byKey(const Key('socialChallengeCartButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Warenkorb'));
    await tester.pumpAndSettle();

    expect(find.text('Basmati Reis'), findsOneWidget);
    expect(find.text('Bio Tomaten stückig'), findsOneWidget);
    expect(find.text('Salatgurke'), findsOneWidget);

    await binding.takeScreenshot('social-feed-cart-flow');
  });
}
