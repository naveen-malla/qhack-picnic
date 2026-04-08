import 'package:flutter/material.dart';
import 'package:qhack_picnic/waren_korbscreen.dart';

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String assetPath;
}

const foodCatalog = <FoodItem>[
  FoodItem(
    id: 'salatgurke',
    name: 'Salatgurke',
    description: '1 Stück mind. 300g',
    price: 0.89,
    assetPath: 'assets/foods/salatgurke.png',
  ),
  FoodItem(
    id: 'cordon_bleu',
    name: 'Hähnchen Cordon-Bleu',
    description: '245g · €14.24/kg',
    price: 3.49,
    assetPath: 'assets/foods/cordon_bleu.png',
  ),
  FoodItem(
    id: 'leerdammer_original',
    name: 'Leerdammer Original',
    description: '140g · €20.64/kg',
    price: 2.89,
    assetPath: 'assets/foods/leerdammer_original.png',
  ),
  FoodItem(
    id: 'gefluegel_mortadella',
    name: 'Geflügel-Mortadella',
    description: 'Wiesenhof · 100g · €16.90/kg',
    price: 1.69,
    assetPath: 'assets/foods/gefluegel_mortadella.png',
  ),
  FoodItem(
    id: 'sammys_super',
    name: 'Sammys Supe..',
    description: 'Harry · 750g · €3.32/kg',
    price: 2.49,
    assetPath: 'assets/foods/sammys_super.png',
  ),
  FoodItem(
    id: 'bio_tomaten_stueckig',
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g · €1.98/kg',
    price: 0.79,
    assetPath: 'assets/foods/bio_tomaten_stueckig.png',
  ),
  FoodItem(
    id: 'suesskartoffel_pommes',
    name: 'Süßkartoffel Pommes',
    description: 'Edeka Herzstücke · 500g · €4.58/kg',
    price: 2.29,
    assetPath: 'assets/foods/suesskartoffel_pommes.png',
  ),
  FoodItem(
    id: 'trauben_hell',
    name: 'Trauben hell',
    description: '500g · €5.18/kg',
    price: 2.59,
    assetPath: 'assets/foods/trauben_hell.png',
  ),
  FoodItem(
    id: 'knoppers',
    name: 'Knoppers',
    description: 'Storck · 8 Stück · 200g · €12.45/kg',
    price: 2.49,
    assetPath: 'assets/foods/knoppers.png',
  ),
  FoodItem(
    id: 'wasser_medium',
    name: 'Wasser Medium',
    description: 'Gerolsteiner · 1.5L · €0.73/L',
    price: 1.09,
    assetPath: 'assets/foods/wasser_medium.png',
  ),
  FoodItem(
    id: 'zucchini',
    name: 'Zucchini',
    description: '1 Stück · €3.96/kg',
    price: 0.99,
    assetPath: 'assets/foods/zucchini.png',
  ),
  FoodItem(
    id: 'hackfleisch_pute',
    name: 'Hackfleisch Pute',
    description: '400g · €10.73/kg',
    price: 4.29,
    assetPath: 'assets/foods/hackfleisch_pute.png',
  ),
  FoodItem(
    id: 'bio_vollmilch',
    name: 'Bio H‑Vollmilch 3,8%',
    description: 'Edeka Bio · 1L',
    price: 1.25,
    assetPath: 'assets/foods/bio_vollmilch.png',
  ),
  FoodItem(
    id: 'grana_padano',
    name: 'Grana Padano gerieben',
    description: 'Edeka Herzstücke · 100g · €22.90/kg',
    price: 2.29,
    assetPath: 'assets/foods/grana_padano.png',
  ),
  FoodItem(
    id: 'haehnchenbrustfilet',
    name: 'Hähnchenbrustfilet',
    description: 'Gut&Günstig · 600g · €11.32/kg',
    price: 6.79,
    assetPath: 'assets/foods/haehnchenbrustfilet.png',
  ),
  FoodItem(
    id: 'lachsfilet',
    name: 'Lachsfilet',
    description: 'Deutsche See · 250g · €27.56/kg',
    price: 6.89,
    assetPath: 'assets/foods/lachsfilet.png',
  ),
  FoodItem(
    id: 'bio_raeucherlachs',
    name: 'Bio Räucherlachs',
    description: 'Edeka Bio · 100g · €39.90/kg',
    price: 3.99,
    assetPath: 'assets/foods/bio_raeucherlachs.png',
  ),
  FoodItem(
    id: 'bio_hackfleisch_rind',
    name: 'Bio Hackfleisch Rind',
    description: 'Bioland · 400g · €18.73/kg',
    price: 7.49,
    assetPath: 'assets/foods/bio_hackfleisch_rind.png',
  ),
  FoodItem(
    id: 'mein_lieblings_lachs',
    name: 'Mein Lieblings Lachs',
    description: 'Krone · 100g · €44.90/kg',
    price: 4.49,
    assetPath: 'assets/foods/mein_lieblings_lachs.png',
  ),
  FoodItem(
    id: 'bio_rindergulasch',
    name: 'Bio Rindergulasch',
    description: 'Bioland · ca. 400g · €20.70/kg',
    price: 8.28,
    assetPath: 'assets/foods/bio_rindergulasch.png',
  ),
];

void main() {
  final startOnSmartBasket = Uri.base.queryParameters['smartBasket'] == '1';
  runApp(MyApp(startOnSmartBasket: startOnSmartBasket));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.startOnSmartBasket});

  final bool startOnSmartBasket;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3E7D2A); // Picnic-like green
    return MaterialApp(
      title: 'Picnic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5F2),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF333333),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5B534E),
          ),
        ),
      ),
      home: startOnSmartBasket
          ? const SmartBasketReviewScreen()
          : const PicnicShell(),
    );
  }
}

class PicnicShell extends StatefulWidget {
  const PicnicShell({super.key});

  @override
  State<PicnicShell> createState() => _PicnicShellState();
}

class _PicnicShellState extends State<PicnicShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DiscoverScreen(),
      const _PlaceholderScreen(title: 'Favoriten'),
      const _PlaceholderScreen(title: 'Kochen'),
      const _PlaceholderScreen(title: 'Suchen'),
      const WarenKorbscreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Entdecken',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoriten',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Kochen',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Suchen'),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Warenkorb',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width >= 420 ? 20.0 : 16.0;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            8,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Wähle deine Lieferzeit ›',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person_outline),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 210,
            child: PageView(
              controller: PageController(viewportFraction: 0.92),
              children: const [
                _HeroCard(
                  title: 'Klick, Klick, Grillglück',
                  subtitle: 'Alles was du brauchst an einem Ort',
                  imagePath: 'assets/foods/haehnchenbrustfilet.png',
                ),
                _HeroCard(
                  title: 'Hereinschauen im Markthallen',
                  subtitle: 'Das Beste von heute',
                  imagePath: 'assets/foods/trauben_hell.png',
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            14,
            horizontalPadding,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: _WelcomeCard(
              onSmartBasket: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SmartBasketReviewScreen(),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            8,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Diese gratis Produkte warten auf dich',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            18,
          ),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _GiftCard(index: i + 1),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            8,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Entdecke unser Sortiment ›',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            24,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: foodCatalog.length,
            itemBuilder: (context, idx) {
              final item = foodCatalog[idx];
              final bgColors = [
                const Color(0xFFE7EEDD),
                const Color(0xFFF1E1E1),
                const Color(0xFFE9F0F7),
                const Color(0xFFF7F0E2),
              ];

              return _ProductCard(
                data: _ProductCardData(
                  title: item.name,
                  subtitle: item.description,
                  price: item.price.toStringAsFixed(2),
                  bg: bgColors[idx % bgColors.length],
                  assetPath: item.assetPath,
                ),
                onAdd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} hinzugefügt (demo)')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SmartBasketReviewScreen extends StatelessWidget {
  const SmartBasketReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final recipeItems = <_SmartBasketItem>[
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'salatgurke'),
        reasons: const ['Recipe ingredient', 'Best match in stock'],
      ),
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'haehnchenbrustfilet'),
        reasons: const ['Recipe ingredient', 'Popular choice'],
      ),
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'bio_tomaten_stueckig'),
        reasons: const ['Recipe ingredient', 'In stock'],
      ),
    ];

    final staples = <_SmartBasketItem>[
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'bio_vollmilch'),
        reasons: const ['Your usual', 'Best value'],
      ),
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'knoppers'),
        reasons: const ['Frequent purchase', 'In stock'],
      ),
      _SmartBasketItem.fromFood(
        foodCatalog.firstWhere((e) => e.id == 'wasser_medium'),
        reasons: const ['Frequent purchase', 'Great with breakfast'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Smart Basket'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
            tooltip: 'How it works',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _NeedsReviewBanner(onTap: () => _showNeedsReviewInfo(context)),
          const SizedBox(height: 14),
          Text('For your recipes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...recipeItems.map((i) => _SmartBasketItemRow(item: i)),
          const SizedBox(height: 18),
          Text('Staples & usuals', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...staples.map((i) => _SmartBasketItemRow(item: i)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Undo Smart Basket'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Go to basket (demo)')),
                  );
                },
                child: const Text('Go to basket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNeedsReviewInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Needs review',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Some items may have substitutions or low confidence. Tap “Why” on an item to see the reasoning.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NeedsReviewBanner extends StatelessWidget {
  const _NeedsReviewBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8DD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFF9C6D2B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Needs review: substitutions / low confidence',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartBasketItem {
  const _SmartBasketItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.reasons,
    required this.assetPath,
  });

  factory _SmartBasketItem.fromFood(
    FoodItem item, {
    required List<String> reasons,
  }) {
    return _SmartBasketItem(
      title: item.name,
      subtitle: item.description,
      price: item.price.toStringAsFixed(2),
      reasons: reasons,
      assetPath: item.assetPath,
    );
  }

  final String title;
  final String subtitle;
  final String price;
  final List<String> reasons;
  final String assetPath;
}

class _SmartBasketItemRow extends StatefulWidget {
  const _SmartBasketItemRow({required this.item});

  final _SmartBasketItem item;

  @override
  State<_SmartBasketItemRow> createState() => _SmartBasketItemRowState();
}

class _SmartBasketItemRowState extends State<_SmartBasketItemRow> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showWhy(context, widget.item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF0E8DD),
                    child: Image.asset(
                      widget.item.assetPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.subtitle,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            widget.item.price,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showWhy(context, widget.item),
                            icon: const Icon(Icons.help_outline, size: 18),
                            label: const Text('Why'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: qty <= 0
                          ? null
                          : () => setState(() => qty = (qty - 1).clamp(0, 99)),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Decrease',
                    ),
                    Text('$qty', style: theme.textTheme.titleMedium),
                    IconButton(
                      onPressed: () =>
                          setState(() => qty = (qty + 1).clamp(0, 99)),
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Increase',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhy(BuildContext context, _SmartBasketItem item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why this item',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...item.reasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(r)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xAA000000), Color(0x00000000)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onSmartBasket});

  final VoidCallback onSmartBasket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bereit für deine 1. Bestellung?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('Willkommen ♥'),
                      ),
                      FilledButton(
                        onPressed: onSmartBasket,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('Smart Basket (1 Tap)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E9E3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 34,
                color: Color(0xFF5B534E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 120,
        color: const Color(0xFFF1E9E3),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.redeem, size: 46, color: Color(0xFFB59C8D)),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFDFD6CF),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B534E),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8F2A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Auspacken'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardData {
  const _ProductCardData({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.bg,
    required this.assetPath,
  });

  final String title;
  final String subtitle;
  final String price;
  final Color bg;
  final String assetPath;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.data, required this.onAdd});

  final _ProductCardData data;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: data.bg),
                Image.asset(data.assetPath, fit: BoxFit.cover),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: InkWell(
                    onTap: onAdd,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${data.title} ›',
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          data.price,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.subtitle,
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
