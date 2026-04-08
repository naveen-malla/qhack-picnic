import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qhack_picnic/main.dart';
import 'package:qhack_picnic/social_screen.dart';

void main() {
  Future<void> pumpSocialFeed(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SocialScreen(
              recipePost: const SocialRecipePostData(
                authorName: 'Anna F.',
                authorSubtitle: 'teilt heute ihr Feierabendgericht',
                dayLabel: 'Veggie Day 43',
                title: 'Tomaten-Reis-Bowl',
                caption:
                    'Drei Zutaten, eine Portion und genau der richtige Mix aus warm, frisch und unkompliziert.',
                imageAssetPath: 'assets/foods/rice_bowl.jpg',
                metrics: [
                  SocialMetric(value: '410', label: 'kcal'),
                  SocialMetric(value: '11g', label: 'Protein'),
                  SocialMetric(value: '62g', label: 'Carbs'),
                  SocialMetric(value: '14g', label: 'Fat'),
                ],
                ingredients: [
                  SocialIngredientLine(
                    name: 'Basmati Reis',
                    detail: '1 x 500 g Packung',
                  ),
                  SocialIngredientLine(
                    name: 'Bio Tomaten stückig',
                    detail: '1 x 400 g Dose',
                  ),
                  SocialIngredientLine(
                    name: 'Zucchini',
                    detail: '1 x Stück',
                  ),
                ],
                likes: 27,
                comments: 3,
                tipLabel:
                    'Tippe auf das Bild, um die Zutatenliste wie eine Karte umzudrehen.',
              ),
              challengePost: const SocialChallengePostData(
                authorName: 'Sarah L.',
                authorSubtitle: 'hat die Wochen-Challenge gestartet',
                title: '3 saisonale Gemüse bis Sonntag',
                description:
                    'Hol dir das Starter-Kit, koche etwas Frisches und bring beim nächsten Picnic-Abend ein buntes Gericht mit.',
                rewardLabel: 'Bonus-Los fur die Verlosung',
                participantCount: 33,
                likes: 12,
                communityImagePaths: [
                  'assets/foods/salatgurke.jpg',
                  'assets/foods/tomaten.jpg',
                  'assets/foods/zucchini.png',
                ],
              ),
              onAddRecipeItems: () {
                wishlistStore.inc('rice');
                wishlistStore.inc('bio_tomaten_stueckig');
                wishlistStore.inc('zucchini');
              },
              onAddChallengeStarterKit: () {
                wishlistStore.inc('salatgurke');
                wishlistStore.inc('bio_tomaten_stueckig');
                wishlistStore.inc('zucchini');
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpBasket(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BasketWishlistScreen())),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    wishlistStore.clear();
  });

  tearDown(() {
    wishlistStore.clear();
  });

  testWidgets('social recipe flips and adds ingredients to basket', (
    WidgetTester tester,
  ) async {
    await pumpSocialFeed(tester);

    expect(find.text('Tomaten-Reis-Bowl'), findsWidgets);
    expect(find.text('Tippen'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('socialRecipeFlipArea')));
    await tester.tap(find.byKey(const Key('socialRecipeFlipArea')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Zutaten'), findsOneWidget);
    expect(find.textContaining('Zucchini'), findsOneWidget);
    expect(wishlistStore.qtyById, isEmpty);

    await tester.tap(find.byKey(const Key('socialRecipeAddButton')));
    await tester.pumpAndSettle();

    expect(wishlistStore.qtyById['rice'], 1);
    expect(wishlistStore.qtyById['bio_tomaten_stueckig'], 1);
    expect(wishlistStore.qtyById['zucchini'], 1);

    await pumpBasket(tester);

    expect(find.text('Basmati Reis'), findsOneWidget);
    expect(find.text('Bio Tomaten stückig'), findsOneWidget);
  });

  testWidgets('challenge join toggle and starter kit stay interactive', (
    WidgetTester tester,
  ) async {
    await pumpSocialFeed(tester);

    await tester.scrollUntilVisible(
      find.text('3 saisonale Gemüse bis Sonntag'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 saisonale Gemüse bis Sonntag'), findsOneWidget);
    expect(find.text('33 machen schon mit'), findsOneWidget);

    await tester.tap(find.byKey(const Key('socialChallengeJoinButton')));
    await tester.pumpAndSettle();

    expect(find.text('Du bist dabei'), findsOneWidget);
    expect(find.text('34 machen schon mit'), findsOneWidget);

    await tester.tap(find.byKey(const Key('socialChallengeCartButton')));
    await tester.pumpAndSettle();

    expect(wishlistStore.qtyById['salatgurke'], 1);
    expect(wishlistStore.qtyById['bio_tomaten_stueckig'], 1);
    expect(wishlistStore.qtyById['zucchini'], 1);

    await pumpBasket(tester);

    expect(find.text('Salatgurke'), findsOneWidget);
  });
}
