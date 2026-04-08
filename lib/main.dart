import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

final wishlistStore = WishlistStore();
final uiRecording = ValueNotifier<bool>(false);

FoodItem? catalogById(String id) {
  for (final item in foodCatalog) {
    if (item.id == id) return item;
  }
  return null;
}

String _formatEuro(double v) {
  // Simple German-ish formatting (no intl dependency).
  return v.toStringAsFixed(2).replaceAll('.', ',');
}

String _normalizeItemName(String s) {
  final t = s.trim().toLowerCase();
  if (t.isEmpty) return '';
  return t.replaceAll(RegExp(r'\s+'), '_');
}

FoodItem? mapToCatalog(String normalized) {
  final n = normalized.trim().toLowerCase();
  final alias = <String, String>{
    // Original requested ids
    'leer_dammer': 'leerdammer_original',
    'leerdammer': 'leerdammer_original',
    'sandwich_bread': 'sandwich_bread',
    'salatgurke': 'salatgurke',
    'salami': 'salami',
    'sauce': 'sauce',

    // Model normalizations (Gemini often returns English)
    'cucumber': 'salatgurke',
    'bio_tomaten_stueckig': 'bio_tomaten_stueckig',
    'tomatoes': 'bio_tomaten_stueckig',
    'tomato': 'bio_tomaten_stueckig',
    'leerdammer_cheese': 'leerdammer_original',
    'leerdammer_cheese.': 'leerdammer_original',
    'leerdammer_cheese,': 'leerdammer_original',
    'sandwich_bread.': 'sandwich_bread',
    'sandwich_bread,': 'sandwich_bread',
  };

  final mappedId = alias[n];
  if (mappedId != null) return catalogById(mappedId);

  for (final item in foodCatalog) {
    final name = item.name.toLowerCase().replaceAll(' ', '_');
    if (name.contains(n) || n.contains(name)) return item;
  }
  return null;
}

class WishlistStore extends ChangeNotifier {
  static const apiBase = 'http://127.0.0.1:5001';
  static const apiKey = String.fromEnvironment('WISHLIST_API_KEY', defaultValue: 'dev-token');

  final Map<String, int> qtyById = {};
  Timer? _pollTimer;
  bool _polling = false;
  bool _busy = false;

  void startPolling() {
    if (_polling) return;
    _polling = true;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());
    Future<void>.delayed(Duration.zero, _pollOnce);
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _polling = false;
  }

  void clear() {
    qtyById.clear();
    notifyListeners();
  }

  double get totalCost {
    var total = 0.0;
    for (final e in qtyById.entries) {
      final item = catalogById(e.key);
      if (item == null) continue;
      total += item.price * e.value;
    }
    return total;
  }

  void setQty(String id, int qty) {
    final next = qty.clamp(0, 9999);
    if (next <= 0) {
      if (qtyById.remove(id) != null) notifyListeners();
      return;
    }
    if (qtyById[id] == next) return;
    qtyById[id] = next;
    notifyListeners();
  }

  void inc(String id, {int by = 1}) {
    setQty(id, (qtyById[id] ?? 0) + (by <= 0 ? 1 : by));
  }

  void dec(String id, {int by = 1}) {
    setQty(id, (qtyById[id] ?? 0) - (by <= 0 ? 1 : by));
  }

  void addItemsFromExtracted(Map<String, dynamic> extracted) {
    final items = (extracted['items'] as List?) ?? const [];
    var changed = false;
    for (final it in items) {
      final m = (it as Map?)?.cast<String, dynamic>();
      final rawName = (m?['name'] ?? '').toString();
      final norm = _normalizeItemName(rawName);
      if (norm.isEmpty) continue;
      final catalogItem = mapToCatalog(norm);
      if (catalogItem == null) continue;
      final q = m?['quantity'];
      final qty = q is num ? q.toInt() : 1;
      final add = qty <= 0 ? 1 : qty;
      qtyById[catalogItem.id] = (qtyById[catalogItem.id] ?? 0) + add;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> _pollOnce() async {
    if (_busy) return;
    _busy = true;
    try {
      while (true) {
        final nextUri = Uri.parse('$apiBase/api/wishlist/next').replace(queryParameters: {'api_key': apiKey});
        final nextResp = await http.get(nextUri);
        if (nextResp.statusCode == 204) return;
        if (nextResp.statusCode != 200) return;

        final payload = jsonDecode(nextResp.body) as Map<String, dynamic>;
        final wishlistId = (payload['id'] ?? '').toString();
        final from = (payload['from'] ?? '').toString();
        final extracted = (payload['extracted'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

        addItemsFromExtracted(extracted);

        if (wishlistId.isEmpty || from.isEmpty) continue;
        final normalizedNames = <String>[];
        final items = (extracted['items'] as List?) ?? const [];
        for (final it in items) {
          final m = (it as Map?)?.cast<String, dynamic>();
          final rawName = (m?['name'] ?? '').toString();
          final norm = _normalizeItemName(rawName);
          if (norm.isNotEmpty) normalizedNames.add(norm);
        }

        final confirmUri = Uri.parse('$apiBase/api/wishlist/confirm').replace(queryParameters: {'api_key': apiKey});
        await http.post(
          confirmUri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'id': wishlistId, 'from': from, 'items': normalizedNames}),
        );
      }
    } catch (_) {
      return;
    } finally {
      _busy = false;
    }
  }
}

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

const reorderCatalog = <FoodItem>[
  FoodItem(
    id: 'leerdammer_original',
    name: 'Leerdammer Original',
    description: '140g · €20.64/kg',
    price: 2.89,
    assetPath: 'assets/foods/leer_dammer.jpg',
  ),
  FoodItem(
    id: 'bio_tomaten_stueckig',
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g · €1.98/kg',
    price: 0.79,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
];
const foodCatalog = <FoodItem>[
  FoodItem(
    id: 'leerdammer_original',
    name: 'Leerdammer Original',
    description: '140g · €20.64/kg',
    price: 2.89,
    assetPath: 'assets/foods/leer_dammer.jpg',
  ),
  FoodItem(
    id: 'cordon_bleu',
    name: 'Hähnchen Cordon-Bleu',
    description: '245g · €14.24/kg',
    price: 3.49,
    assetPath: 'assets/foods/cordon_bleu.jpg',
  ),
  FoodItem(
    id: 'salatgurke',
    name: 'Salatgurke',
    description: '1 Stück mind. 300g',
    price: 0.89,
    assetPath: 'assets/foods/salatgurke.jpg',
  ),
  FoodItem(
    id: 'gefluegel_mortadella',
    name: 'Geflügel-Mortadella',
    description: 'Wiesenhof · 100g · €16.90/kg',
    price: 1.69,
    assetPath: 'assets/foods/geflügel.jpg',
  ),
  FoodItem(
    id: 'Vollkorn-Brot',
    name: 'Vollkorn-Brot',
    description: 'Brot · 750g · €3.32/kg',
    price: 2.49,
    assetPath: 'assets/foods/bread.jpg',
  ),
  FoodItem(
    id: 'salami',
    name: 'Salami',
    description: '100g · sliced (demo)',
    price: 2.19,
    assetPath: 'assets/foods/geflügel.jpg',
  ),
  FoodItem(
    id: 'sandwich_bread',
    name: 'Sandwich Bread',
    description: 'Brot · 750g · €3.32/kg',
    price: 2.49,
    assetPath: 'assets/foods/bread.jpg',
  ),
  FoodItem(
    id: 'sauce',
    name: 'Sauce',
    description: 'Condiment (demo)',
    price: 1.49,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
  FoodItem(
    id: 'bio_tomaten_stueckig',
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g · €1.98/kg',
    price: 0.79,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
  FoodItem(
    id: 'ketchup',
    name: 'Ketchup',
    description: 'Heinz · 500ml · €5.98/L',
    price: 2.99,
    assetPath: 'assets/foods/ketchup.jpg',
  ),
  FoodItem(
    id: 'orange_juice',
    name: 'Orangensaft',
    description: 'Frisch gepresst · 1L',
    price: 1.89,
    assetPath: 'assets/foods/orange_juice.jpg',
  ),
  FoodItem(
    id: 'rice',
    name: 'Basmati Reis',
    description: 'Uncle Ben\'s · 500g · €3.98/kg',
    price: 1.99,
    assetPath: 'assets/foods/rice.jpg',
  ),
];

void main() {
  wishlistStore.startPolling();
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
      debugShowCheckedModeBanner: false,
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

  void _goToFavoriten() => setState(() => _tabIndex = 1);

  @override
  void initState() {
    super.initState();
    wishlistStore.addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    wishlistStore.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DiscoverScreen(onGoToFavoriten: _goToFavoriten),
      const FavoritenScreen(),
      const _PlaceholderScreen(title: 'Kochen'),
      const _PlaceholderScreen(title: 'Suchen'),
      const BasketWishlistScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: pages[_tabIndex]),
          ValueListenableBuilder<bool>(
            valueListenable: uiRecording,
            builder: (context, isRec, _) {
              if (!isRec) return const SizedBox.shrink();
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    // Extreme top-to-bottom overlay (above SafeArea).
                    color: const Color(0xFFFFF3B0).withOpacity(0.18),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Entdecken',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoriten',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Kochen',
          ),
          const NavigationDestination(icon: Icon(Icons.search), label: 'Suchen'),
          NavigationDestination(
            icon: _CartNavIcon(
              outlined: true,
              totalCost: wishlistStore.totalCost,
            ),
            selectedIcon: _CartNavIcon(
              outlined: false,
              totalCost: wishlistStore.totalCost,
            ),
            label: 'Warenkorb',
          ),
        ],
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon({required this.outlined, required this.totalCost});

  final bool outlined;
  final double totalCost;

  @override
  Widget build(BuildContext context) {
    final show = totalCost > 0.001;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(outlined ? Icons.shopping_basket_outlined : Icons.shopping_basket),
        if (show)
          Positioned(
            right: -14,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _formatEuro(totalCost),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
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

class BasketWishlistScreen extends StatefulWidget {
  const BasketWishlistScreen({super.key});

  @override
  State<BasketWishlistScreen> createState() => _BasketWishlistScreenState();
}

class _BasketWishlistScreenState extends State<BasketWishlistScreen> {
  @override
  void initState() {
    super.initState();
    wishlistStore.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    wishlistStore.removeListener(_onStoreChange);
    super.dispose();
  }

  void _onStoreChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = wishlistStore.qtyById.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final total = entries.fold<double>(0.0, (sum, e) {
      final item = catalogById(e.key);
      if (item == null) return sum;
      return sum + item.price * e.value;
    });
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Morgen 17:25 - 19:15',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B534E),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            children: [
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Text('Noch keine Artikel im Warenkorb.'),
                )
              else ...[
                ...entries.map((e) {
                  final item = catalogById(e.key);
                  if (item == null) return const SizedBox.shrink();
                  final qty = e.value;
                  final lineTotal = item.price * qty;

                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _QtyPill(qty: qty),
                        const SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 44,
                            height: 44,
                            color: const Color(0xFFF0E8DD),
                            child: Image.asset(item.assetPath, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E2A27),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7A716B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatEuro(lineTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E2A27),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QtyStepper(
                          onDecrement: () => wishlistStore.dec(item.id),
                          onIncrement: () => wishlistStore.inc(item.id),
                        ),
                      ],
                    ),
                  );
                }),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Produkte als eigenes Rezept speichern  ›',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2A27),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset * 0),
          child: SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: entries.isEmpty ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Zur Kasse',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 86,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '€ ${_formatEuro(total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FavoritenScreen extends StatefulWidget {
  const FavoritenScreen({super.key});

  @override
  State<FavoritenScreen> createState() => _FavoritenScreenState();
}

class _FavoritenScreenState extends State<FavoritenScreen> {
  final List<bool> _added = [false, false, false, false, false, false];

  FoodItem _get(String id) => foodCatalog.firstWhere((e) => e.id == id);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final preSelected = [
      _get('leerdammer_original'),
      _get('salatgurke'),
      _get('bio_tomaten_stueckig'),
    ];

    final addable = [
      _get('cordon_bleu'),
      _get('gefluegel_mortadella'),
      _get('Vollkorn-Brot'),
      _get('ketchup'),
      _get('orange_juice'),
      _get('rice'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Bestellen Sie wieder',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 30),
        // Row 1 – pre-selected items
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: preSelected
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _FavoritenCard(
                        item: item,
                        isPreSelected: true,
                        isAdded: false,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 25),
        // Add-to-cart button (right-aligned)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Zum Warenkorb hinzufügen',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 45),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Vorschläge für Sie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        // Rows 2 & 3 – addable items (3 per row)
        for (int row = 0; row < (addable.length / 3).ceil(); row++) ...[
          if (row > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(3, (col) {
                final i = row * 3 + col;
                if (i >= addable.length) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _FavoritenCard(
                      item: addable[i],
                      isPreSelected: false,
                      isAdded: _added[i],
                      onAdd: () => setState(() => _added[i] = !_added[i]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _FavoritenCard extends StatelessWidget {
  const _FavoritenCard({
    required this.item,
    required this.isPreSelected,
    required this.isAdded,
    this.onAdd,
  });

  final FoodItem item;
  final bool isPreSelected;
  final bool isAdded;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square image area — AspectRatio ensures all cards same height
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: isPreSelected
                  ? Border.all(
                      color: const Color(0xFFE53935).withOpacity(0.35),
                      width: 2,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFF4F4F4)),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      item.assetPath,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFBBBBBB),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: isPreSelected
                        ? Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isAdded
                                    ? const Color(0xFFE53935)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isAdded ? Icons.check : Icons.add,
                                size: 16,
                                color: isAdded
                                    ? Colors.white
                                    : const Color(0xFF333333),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: const Color(0xFF1A1A1A),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '€${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFFE53935),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.qty});

  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFEB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$qty',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF3A342F),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.onDecrement, required this.onIncrement});

  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onIncrement,
              child: const Center(child: Icon(Icons.add, size: 18)),
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.8)),
          Expanded(
            child: InkWell(
              onTap: onDecrement,
              child: const Center(child: Icon(Icons.remove, size: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.onGoToFavoriten});

  final VoidCallback? onGoToFavoriten;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  final _recorder = AudioRecorder();
  late final AnimationController _listenAnim;

  @override
  void initState() {
    super.initState();
    _listenAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _listenAnim.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) return;

      if (_isRecording) {
        final path = await _recorder.stop();
        _listenAnim.stop();
        setState(() => _isRecording = false);
        uiRecording.value = false;
        if (path == null || path.isEmpty) return;
        final bytes = await File(path).readAsBytes();
        await _uploadAndApplyVoice(bytes, mimeType: 'audio/m4a');
        return;
      }

      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
        path: outPath,
      );
      _listenAnim.repeat();
      setState(() => _isRecording = true);
      uiRecording.value = true;
    } catch (_) {
      if (mounted) setState(() => _isRecording = false);
      uiRecording.value = false;
    }
  }

  Future<void> _uploadAndApplyVoice(List<int> audioBytes, {required String mimeType}) async {
    try {
      final uri = Uri.parse('${WishlistStore.apiBase}/api/voice/ingest')
          .replace(queryParameters: {'api_key': WishlistStore.apiKey});
      final req = http.MultipartRequest('POST', uri);
      req.fields['mime_type'] = mimeType;
      req.fields['from'] = 'simulator-voice';
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'voice.m4a',
          contentType: MediaType.parse(mimeType),
        ),
      );
      final resp = await req.send();
      final body = await resp.stream.bytesToString();
      if (resp.statusCode != 200) return;
      final data = jsonDecode(body) as Map<String, dynamic>;
      final extracted = (data['extracted'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      wishlistStore.addItemsFromExtracted(extracted);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width >= 420 ? 20.0 : 16.0;
    return Stack(
      children: [
        CustomScrollView(
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
                  onPressed: _toggleRecord,
                  icon: Icon(_isRecording ? Icons.stop_circle : Icons.graphic_eq),
                  tooltip: _isRecording ? 'Stop recording' : 'Voice input',
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
                  imagePath: 'assets/foods/grill.jpg',
                ),
                _HeroCard(
                  title: 'Hereinschauen im Markthallen',
                  subtitle: 'Das Beste von heute',
                  imagePath: 'assets/foods/rice_bowl.jpg',
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
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                  child: InkWell(
                    onTap: widget.onGoToFavoriten,
                    child: Text(
                      'Bestellen Sie wieder ›',
                      style: theme.textTheme.titleMedium,
                    ),
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
            itemCount: reorderCatalog.length,
            itemBuilder: (context, idx) {
              final item = reorderCatalog[idx];
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
        ),
        // Full-screen overlay is handled by `PicnicShell` so it can cover
        // the entire phone area beyond SafeArea.
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
      child: Material(
        color: const Color(0xFFF9E7E8),
        child: InkWell(
          onTap: onSmartBasket,
          child: SizedBox(
            height: 132,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 44, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Willkommen ♥'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '20 € für deinen\nStart bei Picnic',
                              style: theme.textTheme.titleLarge?.copyWith(
                                height: 1.05,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 92,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              const Icon(
                                Icons.local_shipping_rounded,
                                size: 56,
                                color: Color(0xFF6B6B6B),
                              ),
                              Positioned(
                                top: 10,
                                child: Container(
                                  width: 28,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.card_giftcard,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({required this.index});

  final int index;

  static const _backgroundImages = [
    'assets/foods/blue_icon.png',
    'assets/foods/pink_icon.png',
    'assets/foods/yellow_icon.png',
  ];

  @override
  Widget build(BuildContext context) {
    final bgImage = _backgroundImages[(index - 1) % _backgroundImages.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(bgImage, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xBB000000)],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.85),
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
                        color: Colors.white.withOpacity(0.92),
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
