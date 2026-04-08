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
    description: '140g',
    price: 2.89,
    assetPath: 'assets/foods/leer_dammer.jpg',
  ),
  _Ingredient(
    name: 'Hähnchen Cordon-Bleu',
    description: '245g',
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
    description: 'Wiesenhof · 100g',
    price: 1.69,
    assetPath: 'assets/foods/geflügel.jpg',
  ),
  _Ingredient(
    name: 'Vollkorn-Brot',
    description: '750g',
    price: 2.49,
    assetPath: 'assets/foods/bread.jpg',
  ),
  _Ingredient(
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g',
    price: 0.79,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
];

// Thumbnails for "Nichts vergessen?" horizontal scroll
const _suggestedAssets = [
  'assets/foods/leer_dammer.jpg',
  'assets/foods/salatgurke.jpg',
  'assets/foods/tomaten.jpg',
  'assets/foods/bread.jpg',
  'assets/foods/cordon_bleu.jpg',
];

class WarenKorbscreen extends StatefulWidget {
  const WarenKorbscreen({super.key});

  @override
  State<WarenKorbscreen> createState() => _WarenKorbscreenState();
}

class _WarenKorbscreenState extends State<WarenKorbscreen> {
  final List<int> _quantities =
      List.filled(_ingredients.length, 1, growable: false);

  double get _total {
    double sum = 0;
    for (int i = 0; i < _ingredients.length; i++) {
      sum += _ingredients[i].price * _quantities[i];
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _DeliveryHeader(),
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < _ingredients.length; i++) ...[
                    _IngredientRow(
                      item: _ingredients[i],
                      quantity: _quantities[i],
                      onDecrement: () => setState(() {
                        if (_quantities[i] > 0) _quantities[i]--;
                      }),
                      onIncrement: () =>
                          setState(() => _quantities[i]++),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                  const SizedBox(height: 16),
                  _SaveAsRecipeRow(),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _CostRow(
                    label: 'Lieferung',
                    valueWidget: Text(
                      'Gratis',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF3E7D2A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CostRow(
                    label: 'Total',
                    sublabel: '(Inkl. MwSt.)',
                    valueWidget: Text(
                      _total.toStringAsFixed(2).replaceAll('.', ','),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _NichtsVergessenSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _OrderButton(total: _total),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DeliveryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.electric_scooter_outlined),
            onPressed: () {},
          ),
          Expanded(
            child: Text(
              'Wähle deine Lieferzeit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Ingredient Row ────────────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.item,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final _Ingredient item;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quantity badge
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF2F2F2),
                  child: const Icon(Icons.image_outlined,
                      size: 24, color: Color(0xFFBBBBBB)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Price (superscript cents)
          _SuperscriptPrice(price: item.price * quantity),
        ],
      ),
    );
  }
}

// ── Superscript price widget ──────────────────────────────────────────────────

class _SuperscriptPrice extends StatelessWidget {
  const _SuperscriptPrice({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    final formatted = price.toStringAsFixed(2);
    final parts = formatted.split('.');
    final euros = parts[0];
    final cents = parts[1];

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(
            text: euros,
            style: const TextStyle(fontSize: 20),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                cents,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Save as recipe row ────────────────────────────────────────────────────────

class _SaveAsRecipeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {},
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            children: const [
              TextSpan(text: 'Produkte als '),
              TextSpan(
                text: 'eigenes Rezept',
                style: TextStyle(
                  color: Color(0xFF3E7D2A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' speichern ›'),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cost summary row ──────────────────────────────────────────────────────────

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    this.sublabel,
    required this.valueWidget,
  });

  final String label;
  final String? sublabel;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (sublabel != null) ...[
            const SizedBox(width: 4),
            Text(sublabel!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[500])),
          ],
          const Spacer(),
          valueWidget,
        ],
      ),
    );
  }
}

// ── "Nichts vergessen?" section ───────────────────────────────────────────────

class _NichtsVergessenSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {},
            child: Text(
              'Nichts vergessen? ›',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestedAssets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Image.asset(
                    _suggestedAssets[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF2F2F2),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Bottom order button ───────────────────────────────────────────────────────

class _OrderButton extends StatelessWidget {
  const _OrderButton({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final parts = total.toStringAsFixed(2).split('.');
    final euros = parts[0];
    final cents = parts[1];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Material(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Wähle deine Lieferzeit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        const TextSpan(
                          text: '€ ',
                          style: TextStyle(fontSize: 15),
                        ),
                        TextSpan(
                          text: euros,
                          style: const TextStyle(fontSize: 20),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              cents,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
