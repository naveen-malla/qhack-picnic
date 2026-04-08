import 'package:flutter/material.dart';

class _Ingredient {
  const _Ingredient({
    required this.name,
    required this.description,
    required this.price,
    required this.assetPath,
  });

  final String name;
  final String description;
  final double price;
  final String assetPath;
}

const _ingredients = <_Ingredient>[
  _Ingredient(
    name: 'Leerdammer Original',
    description: '140g · €20.64/kg',
    price: 2.89,
    assetPath: 'assets/foods/leer_dammer.jpg',
  ),
  _Ingredient(
    name: 'Hähnchen Cordon-Bleu',
    description: '245g · €14.24/kg',
    price: 3.49,
    assetPath: 'assets/foods/cordon_bleu.jpg',
  ),
  _Ingredient(
    name: 'Salatgurke',
    description: '1 Stück mind. 300g',
    price: 0.89,
    assetPath: 'assets/foods/salatgurke.jpg',
  ),
  _Ingredient(
    name: 'Geflügel-Mortadella',
    description: 'Wiesenhof · 100g · €16.90/kg',
    price: 1.69,
    assetPath: 'assets/foods/geflügel.jpg',
  ),
  _Ingredient(
    name: 'Vollkorn-Brot',
    description: 'Brot · 750g · €3.32/kg',
    price: 2.49,
    assetPath: 'assets/foods/bread.jpg',
  ),
  _Ingredient(
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g · €1.98/kg',
    price: 0.79,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
];

class WarenKorbscreen extends StatefulWidget {
  const WarenKorbscreen({super.key});

  @override
  State<WarenKorbscreen> createState() => _WarenKorbscreenState();
}

class _WarenKorbscreenState extends State<WarenKorbscreen> {
  final List<bool> _checked = List.filled(
    _ingredients.length,
    false,
    growable: false,
  );

  double get _total {
    double sum = 0;
    for (int i = 0; i < _ingredients.length; i++) {
      if (_checked[i]) sum += _ingredients[i].price;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkedCount = _checked.where((c) => c).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5F2),
        elevation: 0,
        title: Text('Warenkorb', style: theme.textTheme.titleLarge),
        actions: [
          if (checkedCount > 0)
            TextButton(
              onPressed: () =>
                  setState(() => _checked.fillRange(0, _checked.length, false)),
              child: const Text('Leeren'),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: _ingredients.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _ingredients[index];
          return _IngredientRow(
            item: item,
            checked: _checked[index],
            onChanged: (val) => setState(() => _checked[index] = val ?? false),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$checkedCount Artikel ausgewählt',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '€${_total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: checkedCount == 0 ? null : () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Bestellen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.item,
    required this.checked,
    required this.onChanged,
  });

  final _Ingredient item;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!checked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Left: image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0EBE3),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: Color(0xFFBBB0A8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Middle: title + description + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '€${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right: checkbox
              Checkbox(
                value: checked,
                onChanged: onChanged,
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
